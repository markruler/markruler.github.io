---
date: 2024-08-22T18:00:00+09:00
lastmod: 2024-09-05T21:47:00+09:00
title: "Traceparent 헤더로 클라이언트부터 서버까지 추적하기"
description: "W3C Trace Context"
images: ["/images/web/traceparent-datadog/w3c.webp"]
tags:
  - network
  - monitoring
  - APM
  - trace
categories:
  - blog
---

# 개요

모니터링 도구를 확인해보니 며칠동안 특정 기능에 에러가 발생하고 있었습니다.
해당 에러는 알람 임계점(threshold)보다 낮아서 알람이 발생하지 않았고, 이용자는 버그 리포팅을 하지 않았습니다.
에러 로그를 확인해보니 서버에서는 유효성 검사를 하지 않았고, 클라이언트 앱에서는 유효하지 않은 파라미터를 전달했습니다.
서버에서 유효성 검사를 추가할 수 있겠지만, 클라이언트 앱에서의 잘못된 요청(bug)은 원인을 알 수 없었습니다.
클라이언트 이벤트는 연결되어 있지 않았기 때문입니다.

또 다른 문제가 있었습니다.
서버에서는 정상적인 상태 코드와 함께 100ms 정도의 속도로 응답했지만
클라이언트에서는 4초 이상의 지연이 발생하거나 아래와 같은 Akamai 에러 페이지가 응답되었습니다.
그리고 모든 요청이 아닌 전체 요청의 5% 정도에서만 발생하고 있었습니다.
하지만 국가, Edge IP, User Agent, 요청 URL 등을 확인해봐도 특정 패턴을 보이는 것이 없어서 원인을 알 수 없었습니다.

![Akamai ERR_READ_ERROR](/images/web/traceparent-datadog/akamai-read-error.jpeg)

원인을 찾기 위해 클라이언트에서 요청하는 부분부터 추적하고 싶었습니다.
우리팀에서 사용하는 APM 도구인 데이터독(Datadog)에서는
[RUM(Real User Monitoring)을 APM과 연결하면](https://docs.datadoghq.com/real_user_monitoring/platform/connect_rum_and_traces/?tab=browserrum)
클라이언트부터 서버 Span까지 한눈에 확인할 수 있습니다.
하지만 응답 속도가 Akamai에선 4초 이상이라고 측정되고 Datadog RUM에선 수백ms로 측정되었습니다.
그래서 Datadog 측에 확인을 요청했습니다.
Akamai Datastream 2에서는 요청하고 응답받을 때까지의 duration을 측정하지만,
Datadog RUM에서는 브라우저에서 서버까지의 duration만 측정한다는 답변을 받았습니다(2024년 8월 22일 기준).
게다가 일주일 간 RUM 스크립트를 추가해보니 예상 견적이 만만치 않았습니다.
다른 방법을 찾아야 했습니다.

# Trace Context

W3C 권고안(REC, Recommendation)인 Trace Context[^1]는 분산 추적 통합을 위해 작성되었습니다.
플랫폼마다 Trace 방법이 달라서 추적 흐름이 끊기는 것을 방지하기 위해 통합이 필요하단 이유[^2]였습니다.
Datadog에서 해당 스펙을 지원하고 있기 때문에 활용해보기로 했습니다.
Log와 Trace를 연결해서 어디서 에러가 발생하는지, 어디서 병목이 발생하는지 확인하기로 했습니다.

![datadog-trace-context.png](/images/web/traceparent-datadog/datadog-trace-context.webp)

*[Monitor OTel instrumented apps with support for W3C Trace Context | Datadog](https://www.datadoghq.com/blog/monitor-otel-with-w3c-trace-context/)*

## Traceparent 헤더 형식

- 해당 권고안에 명시된 헤더가 2개(traceparent, tracestate[^3]) 있지만 여기서는 추적을 위한 `traceparent` 헤더만 살펴보겠습니다.
- `{version}-{trace-id}-{parent-id}-{trace-flags}`
  - `version`: 8 bits(1 byte). 현재는 00 고정입니다. 2글자의 16진수. ff is forbidden.
  - `trace-id`: **128 bits(16 bytes) trace ID, 32글자의 16진수. All zeroes forbidden.**
  - `parent-id`: 64 bits(8 bytes) span ID, 16글자의 16진수. All zeroes forbidden.
  - `trace-flags`: 8 bits(1 byte) [비트 필드](https://en.wikipedia.org/wiki/Bit_field).
    데이터독에서는 2가지를 지정할 수 있습니다: Sampled (`01`), not sampled (`00`).
- 예시: `00-8adb122e8b139de4a8744a379b4db39a-45897f550adef5c9-01`

# 테스트 환경

## 전체 네트워크 흐름

Client(Mobile App / Browser) → CDN (Akamai) → [IDC: 방화벽(FortiGate-100E) → L2 Switch → [WAF → L4 Switch → Apache HTTP Server → Application Server]]

# trace_id로 Trace와 Log 연결하기

이 방법은 APM Trace와 Log Collection에 로그가 있어야 합니다.

## 1. Browser에서 요청 시 Traceparent 헤더 추가하기

요청 시 아래 스크립트로 생성한 값을 `Traceparent` 헤더와 함께 보냅니다.

```javascript
/**
 * https://www.w3.org/TR/trace-context-2/#traceparent-header-field-values
 */
class Traceparent {
  constructor(version, traceId, parentId, flags) {
    /**
     * 2HEXDIGLC   ; this document assumes version 00. Version ff is forbidden
     * 
     * @see https://www.w3.org/TR/trace-context-2/#version
     */
    this.version = version;
    /**
     * 32HEXDIGLC  ; 16 bytes array identifier. All zeroes forbidden
     * 
     * @see https://www.w3.org/TR/trace-context-2/#trace-id
     */
    this.traceId = traceId;
    /**
     * 16HEXDIGLC  ; 8 bytes array identifier. All zeroes forbidden
     * 
     * @see https://www.w3.org/TR/trace-context-2/#parent-id
     */
    this.parentId = parentId;
    /**
     * 2HEXDIGLC   ; 8 bit flags.
     * 
     * @see https://www.w3.org/TR/trace-context-2/#trace-flags
     */
    this.flags = flags;
  }
  toString() {
    return `${this.version}-${this.traceId}-${this.parentId}-${this.flags}`;
  }
}

// 랜덤 바이트 생성
// 브라우저에서 사용하기 위해 Node.js의 Buffer 대신 Uint8Array 사용.
function randomBytes(size) {
  const bytes = new Uint8Array(size);
  window.crypto.getRandomValues(bytes);
  return bytes;
}

// 16진수 문자열로 변환
function bufferHex(buffer) {
  return Array.from(buffer)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// 10진수 숫자를 16진수 문자열로 변환
function toHex(number) {
  return number.toString(16).padStart(2, "0");
}

// 버전, traceId, id, flags 생성
function make() {
  const version = toHex(0); // 현재 버전은 항상 `00`이므로 0으로 설정
  const traceId = bufferHex(randomBytes(16));
  const parentId = bufferHex(randomBytes(8));
  const traceFlags = toHex(1); // Datadog: Sampled (01) / not sampled (00)
  return new Traceparent(version, traceId, parentId, traceFlags);
}

export default {
  make,
};
```

## 2. Akamai CDN에서 Traceparent의 값을 로그로 추가하기

Akamai Datastream 2에 **커스텀 필드**를 추가해서 traceparent 헤더의 값을 데이터독에 로그로 전달하도록 설정합니다.

- Properties (Property Manage) > Property 선택 후 규칙을 추가합니다.
- Datadog Log에서 Grok Parser를 활용해 Akamai Datastream - `customField`로 남겨진 `traceparent` 헤더에서 trace_id를 추출합니다.

```grok
# Grok Parser
traceparent_nullif (traceparent:%{traceparent_rule}|traceparent:\^|traceparent:-|traceparent:|-)

traceparent_rule %{_version}-%{_trace_id}-%{_parent_id}-%{_flags}

# Extract from: customField

_version %{regex("[a-zA-Z0-9]*"):traceparent.version}
_trace_id %{regex("[a-zA-Z0-9]*"):traceparent.trace_id}
_parent_id %{regex("[a-zA-Z0-9]*"):traceparent.parent_id}
_flags %{regex("[a-zA-Z0-9]*"):traceparent.flags}
```

## 3. Apache HTTP Server(httpd)에서 Traceparent 헤더 로그 남기기

LogFormat에  `%{header_name}i` 으로 남기면 [헤더의 값을 로그로 남길 수](https://httpd.apache.org/docs/2.4/mod/mod_log_config.html#formats) 있습니다.
httpd의 로그도 Grok Parser를 활용해 traceparent 헤더에서 trace_id를 추출합니다.

```xml
<!-- httpd.conf -->
<IfModule log_config_module>
  LogFormat "%h %l %u %t \"%r\" %>s %b %D \"%{Referer}i\" \"%{User-Agent}i\" \"%{traceparent}i\" %{BALANCER_WORKER_ROUTE}e" combined
  CustomLog /var/log/httpd/access.log combined
</IfModule>
```

```grok
# Grok Parser
_traceparent (%{word:traceparent.version})?(-%{word:traceparent.trace_id})?(-%{word:traceparent.parent_id})?(-%{data:traceparent.flags})?
```

## 4. Java Application (Spring Boot)

`dd.trace.propagation.style` 속성의 기본값은 `datadog,tracecontext`으로 Datadog의 Trace ID가 우선합니다.
이를 `tracecontext,datadog`으로 변경하면 W3C Trace ID를 우선합니다.
물론 여기서는 클라이언트에서 전달한 Trace ID를 사용합니다.

```sh
nohup ~/.jdk/temurin-17.0.6/bin/java \
  -javaagent:/home/encar/tools/datadog/apm-java/dd-java-agent-1.37.0.jar \
  -Ddd.service.name=my-service \
  -Ddd.trace.propagation.style=tracecontext,datadog \
  -jar \
  ${ARTIFACT_PATH}/app.jar \
  --spring.profiles.active=prod \
> /dev/null &
```

- [dd-java-agent 다운로드](https://github.com/DataDog/dd-trace-java/releases)
- W3C의 traceparent는 128비트 Trace ID(32 lowercase hexadecimal characters)인 반면,
  Datadog은 기본적으로 64비트 Trace ID(decimal numbers)를 지원합니다.
- Datadog도 옵션 `dd.trace.128.bit.traceid.generation.enabled`을 추가해서 128비트 Trace ID를 출력할 수 있다고 합니다.

## 5. 결과

Trace에 Log를 연결한 모습은 다음과 같습니다.

![Connect Trace and Log](/images/web/traceparent-datadog/connect-trace-log.webp)

# 마치며

서버에서 발생한 에러는 Trace에서 먼저 확인 후 클라이언트 > CDN > 웹 서버 로그로 확인할 수 있고,
방화벽 이슈로 발생한 에러는 위와 같이 Log Collection에서 확인할 수 있습니다.

Browser 스팬을 연결할 다른 방법이 없는지 데이터독 기술 지원을 요청했지만, RUM을 사용해보라는 답변뿐이었습니다.[^4]
OpenTelemetry(OTel) 도입도 고민했지만, 현재 팀 규모에서 시스템을 더 늘릴 수는 없어서 포기했습니다.

지연 문제도 찾아서 해결되었습니다.
Akamai Datastream에서 정확한 duration을 확인할 수 있었는데 해당 요청들에 대해 기술 지원을 요청했고,
원인은 CDN이 아니라 IDC에 있던 방화벽에서 특정 Akamai Edge IP를 차단하고 있다는 것이었습니다.
아래 이미지는 Akamai Edge IP를 차단 해제했을 때 해소된 모습입니다.

![Solve Network Delay](/images/web/traceparent-datadog/solve-network-delay.webp)

이것을 꼼수라고 해야 할지 모르겠지만, 어찌됐건 해당 작업 후 원인을 알 수 없던 문제들을 해결할 수 있었습니다.

# 참조

- [Trace Context | W3C](https://www.w3.org/TR/trace-context/)
  - [Github(w3c/trace-context) | W3C](https://github.com/w3c/trace-context/tree/main/spec)
  - [Trace context | Google Cloud](https://cloud.google.com/trace/docs/trace-context)
  - [Elastic APM adopts W3C TraceContext | Elastic](https://www.elastic.co/blog/elastic-apm-adopts-w3c-tracecontext)
- Datadog
  - [Connect RUM and Traces](https://docs.datadoghq.com/real_user_monitoring/platform/connect_rum_and_traces/?tab=w3ctracecontext)
  - [Parsing](https://docs.datadoghq.com/logs/log_configuration/parsing/?tab=matchers)
    - [Grok Parser](https://docs.datadoghq.com/service_management/events/pipelines_and_processors/grok_parser/?tab=matchers)
    - [Default Standard Attributes](https://docs.datadoghq.com/standard-attributes/)
  - [Trace Context Propagation](https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/?tab=java)
  - [Configuring the Java Tracing Library](https://docs.datadoghq.com/tracing/trace_collection/library_config/java/)
  - [Monitor OTel instrumented apps with support for W3C Trace Context](https://www.datadoghq.com/blog/monitor-otel-with-w3c-trace-context/)
  - [Remap Custom Severity Values to the Official Log Status](https://docs.datadoghq.com/logs/guide/remap-custom-severity-to-official-log-status/)
  - [Correlated Logs Are Not Showing Up In The Trace ID Panel](https://docs.datadoghq.com/tracing/troubleshooting/correlated-logs-not-showing-up-in-the-trace-id-panel/?tab=jsonlogs)

# 각주

[^1]: W3C의 권고안에는 [레벨](https://www.w3.org/2004/02/Process-20040205/tr.html#maturity-levels)이 있는데
Trace Context는 [2020년 2월](https://www.w3.org/news/2020/trace-context-is-a-w3c-recommendation/) 최고 레벨인 Recommendation(REC)으로 전환된 권고안입니다.
올해(2024년)에는 [Level 2](https://www.w3.org/TR/trace-context-2/)와 [Level 3](https://w3c.github.io/trace-context/)까지 나왔습니다.
[^2]: [Problem Statement](https://www.w3.org/TR/trace-context/#problem-statement)
[^3]: [tracestate](https://www.w3.org/TR/trace-context/#tracestate-header)는 `key=value` 형태로 메타데이터를 전달하기 위해 사용하라고 되어 있는데 선택 사항입니다.
[^4]: Datadog Log Collection에도 Traceparent 헤더를 추가할 수 있지만, [beforeSend API를 사용해야 한다고 합니다](https://github.com/DataDog/browser-sdk/issues/1538). 2024년 8월 기준 RUM보다 직접 추가하는 것이 나은 것 같습니다.
