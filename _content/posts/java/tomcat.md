---
date: 2022-08-23T02:45:00+09:00
lastmod: 2025-03-27T12:39:00+09:00
title: "Tomcat 이해하기"
description: "Servlet Container"
# featured_image: "/images/java/http-servlet-request-flow.png"
images: ["/images/java/http-servlet-request-flow.png"]
socialshare: true
tags:
  - web
  - java
categories:
  - wiki
---

Java Servlet, JavaServer Pages(JSP), 그리고 WebSocket과 같은
**Java 웹 애플리케이션을 실행할 수 있도록 지원**하는
오픈 소스 **웹 애플리케이션 서버**(**서블릿 컨테이너**)입니다.

일반적인 웹 서버(Apache HTTP Server, Nginx 등)는
정적 파일(HTML, CSS, JavaScript 등)을 클라이언트에게 제공하지만,
Tomcat은 **동적인 Java 웹 애플리케이션**을 실행할 수 있는 환경을 제공합니다.

# 역할

- **Servlet 컨테이너**
  - Java Servlet을 실행하고 클라이언트의 요청을 처리하여 응답을 반환합니다.
- **JSP 엔진**
  - JSP(JavaServer Pages)를 컴파일하고 실행합니다.
- **웹 애플리케이션 실행**
  - `web.xml` 설정 파일을 기반으로 웹 애플리케이션을 관리합니다.
- **HTTP 요청 처리**
  - HTTP/HTTPS 프로토콜을 사용하여 클라이언트와 서버 간의 요청-응답을 처리합니다.

# 구조

![Tomcat Architecture](/images/java/tomcat-architecture.png)

*[이미지 출처 - Datadog](https://www.datadoghq.com/blog/tomcat-architecture-and-performance/)*

```xml
<!-- server.xml -->
<?xml version='1.0' encoding='utf-8'?>
<Server port="8005" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JasperListener" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <GlobalNamingResources>
    <Resource name="UserDatabase"
              auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1" redirectPort="8443" connectionTimeout="20000" />
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
      </Realm>
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve"
              directory="logs"
              prefix="localhost_access_log." suffix=".txt"
              pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
```

## Server

**카탈리나(Catalina) 서버**는 Tomcat 아키텍처 전체를 나타내며 서블릿 컨테이너를 말합니다.
즉, 서블릿을 실행하기 위한 환경을 제공합니다.
이러한 카탈리나 서버에는 하나 이상의 서비스(Service)가 포함됩니다.
1개의 서비스는 1개 이상의 [커넥터](#connector)와 1개의 [엔진](#engine-container)를 포함합니다.

## Connector

**코요테([Coyote](https://tomcat.apache.org/tomcat-8.5-doc/config/http.html)) 커넥터**는
클라이언트와 Tomcat 사이의 통신을 관리합니다.
TCP 포트에서 요청을 수신 대기(listen)합니다.
그리고 해당 요청을 처리하고 응답을 만들기 위해 엔진(Engine)으로 보냅니다.
기본 구성으로 `HTTP/1.1` 와 `AJP/1.3`(Apache JServ Protocol)[^1] 커넥터가 포함됩니다.

## Container

### Engine Container

Engine은 웹 애플리케이션을 관리하는 가장 상위 컨테이너로 라우팅을 담당합니다.
여러 개의 [Host](#host-container)를 가질 수 있으며, 클라이언트의 요청을 적절한 Host로 전달합니다.

Tomcat은 [재스퍼(Jasper) 엔진](https://tomcat.apache.org/tomcat-8.5-doc/jasper-howto.html)을 사용하여
JSP 파일을 서블릿(Servlet)으로 변환하고 클라이언트에게 전달할 HTML 페이지로 렌더링합니다.

- `org.apache.catalina.LifecycleListener` 를 구현한 구현체는
  해당 엔진이 언제 시작되고 중지되는지 감시하기 위한 컴포넌트입니다.
  설정하면 엔진의 수명 주기(Lifecycle) 이벤트 발생을 감지할 수 있습니다.
- 줄리(JULI: `java.util.logging`) 패키지를 사용해서 로깅(Logging) 기능을 제공합니다.[^2]

### Host Container

Host 요소는 실행 중인 Tomcat 서버의 개별 가상 호스트를 나타냅니다.
클라이언트가 네트워크 이름을 사용하여 Tomcat 서버에 연결하려면
이 이름이 사용자가 속한 인터넷 도메인을 관리하는 DNS(도메인 이름 서비스) 서버에 등록되어 있어야 합니다.
만약 프록시 서버를 사용한다면 필요하지 않을 수도 있습니다.
— 기본적으로 `localhost` 로 입력되어 있습니다.

```plaintext
GET http://www.testwebapp.com/sample/

Request Headers:
Connection: keep-alive
Host: www.testwebapp.com
User-Agent: Apache-HttpClient/4.5.5 (Java/10.0.1)
```

위와 같은 HTTP 요청은 `Host` 헤더와 일치하는 호스트에 매핑합니다.

`CATALINA_BASE` 변수를 사용하여 여러 Tomcat 인스턴스를 구성한 경우[^3]가 아니라면
`CATALINA_BASE` 는 Tomcat을 설치한 디렉토리인 `CATALINA_HOME` 의 값으로 설정됩니다.

### Context Container

Context 요소는 특정 가상 호스트(Host Container) 내에서 실행되는 웹 애플리케이션을 나타냅니다.
단순하게 바라보면 `webapp/` 디렉토리로 구분되는 것이 하나의 컨텍스트입니다.
`Host`는 각각 고유한 경로를 가진 여러 `Context`를 포함할 수 있습니다.
`Context` 인터페이스를 구현한 [`StandardContext`](https://tomcat.apache.org/tomcat-8.5-doc/api/org/apache/catalina/core/StandardContext.html)가
주로 사용됩니다.

서블릿 리스너인 `javax.servlet.ServletContextListener`[^4] 와 `javax.servlet.HttpSessionListener` 등은
`javax.servlet.ServletContextEvent` 를 관리하는 `java.util.EventListener` 를 구현합니다.
— 엔진의 수명 주기를 관리하는 `LifecycleListener` 와 다릅니다.
`LifecycleListener` 를 구현한 `JasperListener` 를 사용해서 Jasper 엔진을 관리하고,
Jasper 엔진을 사용해서 servlet을 관리합니다.

```java
public final class MyServletListener implements ServletContextListener {
    private void addLifeCycleListener(ServletContextEvent event) {
        ApplicationContextFacade source = (ApplicationContextFacade) event.getSource();
        ApplicationContext applicationContext = get(source, "context");
        StandardContext standardContext = get(applicationContext, "context");
        standardContext.addLifecycleListener(new LifecycleListenerImpl());
    }
}
```

### Valve

톰캣의 밸브(Valve)는 컨테이너에 들어오는 HTTP 요청을 가로채는 컴포넌트입니다.
요청이 필터나 서블릿으로 전달되기 전에 처리할 수 있도록 설계되었습니다.
`server.xml`에서 설정하고 Catalina 엔진, Host, Context 등의 컨테이너 내부에서 동작합니다.
밸브는 필터와 달리 톰캣에서만 제공되는 기능입니다.[^5]
대표적으로 접근 로깅, 인증, 보안 기능 등을 제공하기 위해 사용됩니다.[^6]

# Spring application에서 HttpRequest의 흐름

![HTTP Servlet Request](/images/java/http-servlet-request-flow.png)

*[Demonstration](https://github.com/xpdojo/java/tree/study/request-lifecycle-servlet/)*

# Spec 버전 호환성

[출처 문서](https://tomcat.apache.org/whichversion.html)

| Servlet Spec | JSP Spec | EL Spec | WebSocket Spec | Authentication (JASPIC) Spec | Apache Tomcat Version | Supported Java Versions                 |
| ------------ | -------- | ------- | -------------- | ---------------------------- | --------------------- | --------------------------------------- |
| 6.0          | 3.1      | 5.0     | 2.1            | 3.0                          | 10.1.x                | 11 and later                            |
| 5.0          | 3.0      | 4.0     | 2.0            | 2.0                          | 10.0.x                | 8 and later                             |
| 4.0          | 2.3      | 3.0     | 1.1            | 1.1                          | 9.0.x                 | 8 and later                             |
| 3.1          | 2.3      | 3.0     | 1.1            | 1.1                          | 8.5.x                 | 7 and later                             |
| 3.1          | 2.3      | 3.0     | 1.1            | N/A                          | 8.0.x (superseded)    | 7 and later                             |
| 3.0          | 2.2      | 2.2     | 1.1            | N/A                          | 7.0.x (archived)      | 6 and later (7 and later for WebSocket) |
| 2.5          | 2.1      | 2.1     | N/A            | N/A                          | 6.0.x (archived)      | 5 and later                             |
| 2.4          | 2.0      | N/A     | N/A            | N/A                          | 5.5.x (archived)      | 1.4 and later                           |
| 2.3          | 1.2      | N/A     | N/A            | N/A                          | 4.1.x (archived)      | 1.3 and later                           |
| 2.2          | 1.1      | N/A     | N/A            | N/A                          | 3.3.x (archived)      | 1.1 and later                           |

# JMX를 통한 모니터링

[JMX(Java Management eXtensions)](https://en.wikipedia.org/wiki/Java_Management_Extensions)는
애플리케이션을 관리하고 모니터링하기 위한 Java API입니다.

![JMX Architecture](/images/java/jmx-architecture.png)

Probe Level의 MBean(Managed Bean)은 JMX에서 관리되는 객체입니다.
모니터링 및 관리할 수 있는 속성, 연산 및 알림을 제공합니다.
Standard MBean, Dynamic MBean과 추가적으로 Model MBean, Open MBean, Monitor MBean으로 구분되며
이를 통해 구현할 수 있습니다.

MBean Server는 MBean을 관리하고 제공하는 JMX 인프라의 핵심 구성 요소입니다.
애플리케이션은 MBean Server에 등록된 MBean을 조회하고 조작할 수 있습니다.
MBean Server는 MBean의 생명주기를 관리하고,
MBean의 속성 및 연산에 대한 액세스를 제공하며,
알림을 수신하는 등의 작업을 수행합니다.

JMX 에이전트는 JMX 서비스의 일부로 애플리케이션을 관리하기 위한 JMX 인터페이스를 외부로 노출합니다.
에이전트는 MBean Server와 통신하고, 원격 액세스를 허용하며, MBean Server를 통해 애플리케이션의 관리 작업을 수행합니다.
JMX 에이전트는 Java 애플리케이션 내부에 포함되거나 별도의 프로세스로 실행될 수 있습니다.

# 참조

- 책
  - <자바 고양이 톰캣(Tomcat) 이야기> | 최진식
  - <아파치 톰캣 7 따라잡기> | Tanuj Khare
  - <톰캣 최종 분석> (톰캣4, 5) | Budi Kurniawan, Paul Deck
- [Apache Tomcat 8 Architecture](https://tomcat.apache.org/tomcat-8.5-doc/architecture/overview.html) | Apache Tomcat
  - [Server](https://tomcat.apache.org/tomcat-8.5-doc/config/server.html)
  - [Service](https://tomcat.apache.org/tomcat-8.5-doc/config/service.html)
  - [Connectors - HTTP/1.1](https://tomcat.apache.org/tomcat-8.5-doc/config/http.html)
  - [Engine](https://tomcat.apache.org/tomcat-8.5-doc/config/engine.html)
  - [Host](https://tomcat.apache.org/tomcat-8.5-doc/config/host.html)
  - [Context](https://tomcat.apache.org/tomcat-8.5-doc/config/context.html)
- [Tomcat - Architecture and server.xml configuration](https://howtodoinjava.com/tomcat/tomcats-architecture-and-server-xml-configuration-tutorial/) | HowToDoInJava
  - [How web servers work?](https://howtodoinjava.com/tomcat/a-birds-eye-view-on-how-web-servers-work/) | HowToDoInJava
- [Servlet - Flow Of Execution](https://www.geeksforgeeks.org/servlet-flow-of-execution/) | GeeksforGeeks
- [AJP: Apache JServ Protocol](https://en.wikipedia.org/wiki/Apache_JServ_Protocol) - Wikipedia
  - [AJP 프로토콜 모든 것을 분석 해보자](https://ehdvudee.tistory.com/20) | ehdvudee
  - [아파치Apache - 톰캣 Tomcat  연동하는 이유?  AJP란?](https://cheershennah.tistory.com/142) | cheersHena
- [JMX (Java Management Extensions)](https://docs.oracle.com/javase/8/docs/technotes/guides/jmx/) | Oracle
  - [Key metrics for monitoring Tomcat](https://www.datadoghq.com/blog/tomcat-architecture-and-performance/) | Datadog

# 각주

[^1]: 웹 서버(httpd)의 인바운드 요청을 애플리케이션 서버(Tomcat)로 프록시할 수 있는 바이너리 프로토콜입니다.
[^2]: [Logging in Tomcat](https://tomcat.apache.org/tomcat-8.5-doc/logging.html) | Apache Tomcat
[^3]: [Running multiple instances of Tomcat with single server installation](https://howtodoinjava.com/tomcat/running-multiple-instances-of-tomcat-with-single-server-installation/)
[^4]: [ServletContextListener Servlet Listener Example](https://www.digitalocean.com/community/tutorials/servletcontextlistener-servlet-listener-example) | DigitalOcean
[^5]: [Tomcat 의 Valve 와 Servlet Filter](http://i5on9i.blogspot.com/2014/07/tomcat-valve-servlet-filter.html)
[^6]: [Tomcat Valve](https://tomcat.apache.org/tomcat-8.0-doc/config/valve.html)
