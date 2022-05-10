---
date: 2022-05-11T02:19:00+09:00
title: "Java 애플리케이션을 모니터링하면서 Timeout의 중요성 알아가기"
description: "이거 모르는 개발자 많다카더라"
featured_image: "/images/datadog/alert-threshold.png"
images: ["/images/datadog/alert-threshold.png"]
socialshare: true
tags:
  - java
  - spring
  - monitoring
  - timeout
  - datadog
categories:
  - java
  - monitoring
---

# 상황

- 현재팀에서 만들고 있는 애플리케이션은 Spring Framework로 작성하고 있다.
- 계속 특정 애플리케이션과 함께 여러 애플리케이션에서 후속 장애가 발생했다.

## 분석

장애가 발생할 때마다 특정 API가 굉장히 오랜 시간 커넥션이 끊기지 않고 있었다.

![transaction-deadlock](/images/datadog/transaction-deadlock.png)

*`RedisSystemException`은 해당 서버를 죽이면서 Redis와 커넥션이 끊어졌기 때문에 발생한 예외다.
만약 서버를 죽이지 않았다면 끝까지 물고 있었을 것이다.*

시간만 보고도 Timeout이 설정되어 있지 않다는 것을 확인할 수 있다.
설정하지 않으면 **default 값은 -1** 로 타임아웃이 발생하지 않는다.

```java
// org.springframework.transaction.support.AbstractPlatformTransactionManager
TransactionDefinition.TIMEOUT_DEFAULT = -1;
```

하지만 트랜잭션이 왜 저렇게 오래 유지되는지 원인을 알 수 없었다.
그래도 서버 장애가 발생하는 이유는 알 수 있었다.
TImeout이 발생하지 않다보니 해당 트랜잭션들 사이에 데드락(Deadlock)이 발생했고
하나의 서비스 뿐만 아니라 해당 테이블을 사용하는 모든 서비스에 장애가 발생했다.

## 해결

### SQL 튜닝

가장 먼저 시도한 건 SQL 튜닝이었다.
해당 트랜잭션이 왜 끊기지 않았는지 파악할 수 없었지만 해당 SQL을 실행시켰을 때 무려 8초 가량이 소요되었다.
튜닝을 통해 개선한 SQL은 약 1.1초 가량 소요되었다. (이후 1초 이내로 튜닝해보자..!)

### Timeout 설정

Transaction Timeout은 `TransactionManager` 에 설정해야 한다.

```java
<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <constructor-arg ref="dataSource"/>
    <property name="defaultTimeout" value="30"/>
</bean>
```

만약 특정 메서드에만 다른 타임아웃 값을 설정하고 싶다면 메서드 레벨에 `@Transactional` 을 설정한다.

```java
// timeout은 seconds 단위
@Transactional(readOnly = true, timeout = 10)
public Result list(Param param) {
  return repository.list(param);
}
```

# 추가적인 문제

우리 팀은 모니터링 도구로 Datadog을 사용하고 있다.
그런데 알람 임계점(Alert threshold)이 낮게 설정되어 있어서 불필요한 알람이 아주 많이 발생했다.
개발팀은 이 알람들을 무시하고 있었고, 실제로 장애가 발생했을 때 백이면 백 개발팀보다 다른 팀에서 먼저 감지했다.

## Monitoring

그래서 임계점을 높게 설정했다.
이미 Datadog 도입 시점부터 알람이 자주 발생했는데도 고치지 않았던 것으로 보인다.

![alert-threshold](/images/datadog/alert-threshold.png)

*10 minutes Average Latency*

위 평균 지연 시간 그래프에서 스파이크(spike) 부분이 서버 장애가 발생했던 시점이다.
그런데 이전부터 거의 구분할 수 없을 정도로 Alert가 발생하던 것을 확인할 수 있다.
임계점을 높인 이후에는 애플리케이션이 정상일 때 OK로 표시된다.

임계점에 대한 기준은 과거 이력을 보고 설정했다.
장애가 발생하던 시점에 전조가 보이기 시작한 값을 경고 임계점(Warning threshold)으로 설정하고,
증상이 나타났을 때 값을 알람 임계점으로 설정했다.
— 정확한 기준이라고는 할 수 없다. 앞으로도 알람이 발생할 때마다 조정할 예정이다.

## Error Tracing

Datadog의 APM(Application Performance Management) 서비스는
애플리케이션의 성능을 실시간으로 분석할 수 있게 도와주고
에러가 발생했을 때 트레이싱 할 수 있도록 도와준다.
하지만 제대로 트레이싱하기 위해서는 이해할 수 있는 로그가 남아야 한다.

우리 팀에서 작성한 애플리케이션은 Logback을 Logging Framework로 사용하고 있었는데
이를 사용하지 않고 표준 출력(`System.out`)을 사용하는 부분이 군데군데 보였다.
게다가 공통 로깅을 AOP로 분리하지 않고 각각의 메서드에서 처리하고 있었다.

`System.out` 을 사용하면 로그 레벨이나 목적별로 분리해서 설정할 수 없을 뿐더러
애플리케이션 로그 파일에 로그가 남지 않고 Tomcat의 `catalina.out` 에 남는다.
그래서 특정 기능에서 에러가 발생하는데도 로그를 확인하기 어려웠다.

먼저 목적별로 로그 파일을 분리해보자.

```xml
<!-- Logback -->
<configuration>
  <property name="baseDir" value="/home/markruler/logs"/>
  <property name="defaultPattern" value="[%d{yyyy-MM-dd HH:mm:ss}:%X{dd.trace_id:-0} %X{dd.span_id:-0}] %-5level %logger{35} - %msg%n"/>

  <appender name="infoRolling"
            class="ch.qos.logback.core.rolling.RollingFileAppender">
      <file>${baseDir}/data/jdbc.log</file>
      <encoder>
          <charset>UTF-8</charset>
          <pattern>${defaultPattern}</pattern>
      </encoder>
      <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
          <fileNamePattern>${baseDir}/archive/sql.%d{yyyy-MM-dd}.%i.log
          </fileNamePattern>
          <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
              <maxFileSize>200MB</maxFileSize>
          </timeBasedFileNamingAndTriggeringPolicy>
      </rollingPolicy>
  </appender>
  
  <root level="info">
      <appender-ref ref="infoRolling"/>
  </root>
</configuration>
```

그리고 Checkstyle을 도입해서 모든 `System.out`, `System.err`(`printStackTrace` 포함)을 Logger로 대체했다.
코드를 봤을 때 의도된 예외라면 error 레벨이 아닌 info 레벨로 로그를 남겼다.

```xml
<!-- checkstyle.xml -->
<module name="RegexpSinglelineJava">
    <property name="id" value="SystemOutput"/>
    <property name="format" value="^.*System\.(out|err).*$"/>
    <property name="ignoreComments" value="true"/>
    <property name="message"
              value="Don't use System.out/err, use Logger instead."/>
</module>
<module name="RegexpSinglelineJava">
    <property name="id" value="printStackTrace"/>
    <property name="format" value="printStackTrace"/>
    <property name="ignoreComments" value="true"/>
    <property name="message"
              value="Don't use printStackTrace, use Logger instead."/>
</module>
```

특히 선임 중 한 분이 [“200 OK, But”](https://twitter.com/rpbaltazar/status/1458979690790539266) 방식을 선호했기 때문에
그 분이 퇴사하시자마자 HTTP 상태 코드를 분리했다.

![200-ok-but](/images/web/200-ok-but.png)

*"200 OK, but"*

## Spring AOP

마지막으로 AOP를 이용해서 공통 로깅을 분리했다.
예를 들어 트랜잭션 타임아웃이 발생하면 `TransactionTimedOutException` 예외가 발생한다.
그래서 해당 예외를 위한 핸들러를 추가했다.

```java
// org.springframework.transaction.TransactionTimedOutException
org.springframework.transaction.TransactionTimedOutException: Transaction timed out: deadline was Wed May 04 16:42:38 KST 2022
  at org.springframework.transaction.support.ResourceHolderSupport.checkTransactionTimeout(ResourceHolderSupport.java:141)
  at org.springframework.transaction.support.ResourceHolderSupport.getTimeToLiveInMillis(ResourceHolderSupport.java:130)
  at org.springframework.transaction.support.ResourceHolderSupport.getTimeToLiveInSeconds(ResourceHolderSupport.java:114)
  at org.mybatis.spring.transaction.SpringManagedTransaction.getTimeout(SpringManagedTransaction.java:139)
  at org.apache.ibatis.executor.SimpleExecutor.prepareStatement(SimpleExecutor.java:87)
  at org.apache.ibatis.executor.SimpleExecutor.doQuery(SimpleExecutor.java:62)
  at org.apache.ibatis.executor.BaseExecutor.queryFromDatabase(BaseExecutor.java:325)
  at org.apache.ibatis.executor.BaseExecutor.query(BaseExecutor.java:156)
  at org.apache.ibatis.executor.CachingExecutor.query(CachingExecutor.java:109)
  at org.apache.ibatis.executor.CachingExecutor.query(CachingExecutor.java:89)
  at org.apache.ibatis.session.defaults.DefaultSqlSession.selectList(DefaultSqlSession.java:151)
  at org.apache.ibatis.session.defaults.DefaultSqlSession.selectList(DefaultSqlSession.java:145)
  at org.apache.ibatis.session.defaults.DefaultSqlSession.selectList(DefaultSqlSession.java:140)
  at org.apache.ibatis.session.defaults.DefaultSqlSession.selectOne(DefaultSqlSession.java:76)
  at sun.reflect.GeneratedMethodAccessor113.invoke(Unknown Source)
  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
  at java.lang.reflect.Method.invoke(Method.java:498)
  at org.mybatis.spring.SqlSessionTemplate$SqlSessionInterceptor.invoke(SqlSessionTemplate.java:434)
  at com.sun.proxy.$Proxy36.selectOne(Unknown Source)
  at org.mybatis.spring.SqlSessionTemplate.selectOne(SqlSessionTemplate.java:167)
  at org.apache.ibatis.binding.MapperMethod.execute(MapperMethod.java:87)
  at org.apache.ibatis.binding.MapperProxy$PlainMethodInvoker.invoke(MapperProxy.java:145)
  at org.apache.ibatis.binding.MapperProxy.invoke(MapperProxy.java:86)
  at com.sun.proxy.$Proxy96.getRecordCount_new(Unknown Source)
  ...
```

```java
@ControllerAdvice
public class ServerErrorAdvice {
    @ResponseBody
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    @ExceptionHandler(TransactionTimedOutException.class)
    public ErrorResponse handleTransactionTimedOutException(TransactionTimedOutException e) {
        return new ErrorResponse(e.toString());
    }
}
```

이때까지만 해도 해결된 것으로 보였다.

# 상황 2

주말이 지나고 월요일 아침, 갑자기 레이턴시가 높아지고 `TransactionTimedOutException` 예외가 발생했다.

## 분석 2

![transaction-timeout](/images/datadog/transaction-timeout.png)

![connection-timeout](/images/datadog/connection-timeout.png)

`TransactionTimedOutException` 이 발생한 요청에서 4~5분의 레이턴시가 발생했다.
먼저 해당 요청들의 로그를 확인해보았다.
외부 API 서버로 요청하는 부분에서 해당 시간대에 일시적으로 Connection Timeout이 발생했던 것을 확인할 수 있었다.

```bash
ERROR ServiceImpl - org.apache.http.conn.HttpHostConnectException: Connect to api.external.com:80 [api.external.com/x.x.x.x] failed: 연결 시간 초과 (Connection timed out)
org.apache.http.conn.HttpHostConnectException: Connect to api.external.com:80 [api.external.com/x.x.x.x] failed: 연결 시간 초과 (Connection timed out)
        at org.apache.http.impl.conn.DefaultHttpClientConnectionOperator.connect(DefaultHttpClientConnectionOperator.java:159)
        at org.apache.http.impl.conn.PoolingHttpClientConnectionManager.connect(PoolingHttpClientConnectionManager.java:373)
        at org.apache.http.impl.execchain.MainClientExec.establishRoute(MainClientExec.java:394)
        at org.apache.http.impl.execchain.MainClientExec.execute(MainClientExec.java:237)
        at org.apache.http.impl.execchain.ProtocolExec.execute(ProtocolExec.java:185)
        at org.apache.http.impl.execchain.RetryExec.execute(RetryExec.java:89)
        at org.apache.http.impl.execchain.RedirectExec.execute(RedirectExec.java:110)
        at org.apache.http.impl.client.InternalHttpClient.doExecute(InternalHttpClient.java:185)
        at org.apache.http.impl.client.CloseableHttpClient.execute(CloseableHttpClient.java:83)
        at org.apache.http.impl.client.CloseableHttpClient.execute(CloseableHttpClient.java:108)
```

로그에서 보듯이 HTTP 요청에 사용한 라이브러리는 `org.apache.httpcomponents.httpclient` 이며 Connection Request Timeout 기본값이 `-1` 이다.
주석에서 가리키는 system default 는 `java.net.SocketOptions.SO_TIMEOUT` (0x1006)이며 10진수로 4,102(ms)이다.

```java
// org.apache.http.client.config.RequestConfig

/**
 * Returns the timeout in milliseconds used when requesting a connection
 * from the connection manager. A timeout value of zero is interpreted
 * as an infinite timeout.
 * <p>
 * A timeout value of zero is interpreted as an infinite timeout.
 * A negative value is interpreted as undefined (system default).
 * </p>
 * <p>
 * Default: {@code -1}
 * </p>
 */
public int getConnectionRequestTimeout() {
    return connectionRequestTimeout;
}
```

그렇다면 왜 4~5분이 걸리는 걸까?
`HikariDataSource` 의 Connection Timeout이 300초로 설정되어 있었기 때문에 메서드 레벨에서 타임아웃이 발생한 것이다.

## 해결 2

`HikariDataSource` 의 Connection Timeout 값을 300,000(ms)에서 30,000(ms)으로 수정했다.
(기본값이 30,000)

```xml
<!-- https://github.com/brettwooldridge/HikariCP -->
<!-- https://github.com/brettwooldridge/HikariCP#frequently-used -->
<bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource" destroy-method="close">
    <constructor-arg>
        <bean class="com.zaxxer.hikari.HikariConfig">
            <constructor-arg>
                <props>
                    <prop key="jdbcUrl">${jdbc-url}</prop>
                    <prop key="username">${username}</prop>
                    <prop key="password">${password}</prop>
                </props>
            </constructor-arg>
            <property name="idleTimeout" value="600000"/>
            <property name="minimumIdle" value="10"/>
            <property name="maximumPoolSize" value="50"/>
            <property name="connectionTimeout" value="30000"/>
        </bean>
    </constructor-arg>
</bean>
```

# 결론

Timeout을 설정하지 않으면 데드락부터 연쇄 서버 장애까지 많은 것을 겪을 수 있다.
부디 Timeout 설정을 잊지 말자.
그리고 유의미한 로깅과 모니터링을 하자! 🧑‍💻

# 더 읽을 거리

## Logging

- [Exception 처리 권고사안](https://www.slipp.net/questions/350) - benelog
- [SLF4J를 이용한 Logging](https://gmlwjd9405.github.io/2019/01/04/logging-with-slf4j.html) - heejeong Kwon
- [Log4j2 및 Logback의 Async Logging 성능 테스트 비교](https://xlffm3.github.io/spring%20&%20spring%20boot/async-logger-performance/) - Jinhong

## Monitoring

- [데이터독(Datadog)이란?](https://www.44bits.io/ko/keyword/datadog) - 44bits
- [Alerting 101: Timeseries metric checks](https://www.datadoghq.com/blog/alerting-101-metric-checks/) - Datadog
- [Introducing recovery thresholds for metric alerts](https://www.datadoghq.com/blog/introducing-recovery-thresholds/) - Datadog
- [Compare a Service’s latency to the previous week](https://docs.datadoghq.com/tracing/guide/week_over_week_p50_comparison/) - Datadog
- [LINE의 장애 보고와 후속 절차 문화](https://engineering.linecorp.com/ko/blog/line-failure-reporting-and-follow-up-process-culture/) - LINE Engineering

## Transaction

- [Data Access - Transaction Management](https://docs.spring.io/spring-framework/docs/5.3.2/reference/html/data-access.html#transaction) - Spring Docs
  - [번역](https://godekdls.github.io/Spring%20Data%20Access/transactionmanagement/) - 토리맘의 한글라이즈 프로젝트
- [응? 이게 왜 롤백되는거지?](https://techblog.woowahan.com/2606/) - 우아한형제들 기술 블로그
- [HikariCP Dead lock에서 벗어나기 (이론편)](https://techblog.woowahan.com/2664/) - 우아한형제들 기술 블로그
- [HikariCP Dead lock에서 벗어나기 (실전편)](https://techblog.woowahan.com/2663/) - 우아한형제들 기술 블로그
