---
date: 2024-08-29T22:38:00+09:00
lastmod: 2024-08-29T22:38:00+09:00
title: "IP로 지리적 위치(Geolocation) 찾기"
description: "CDN에서 위치 정보를 얻는 방법"
featured_image: "/images/network/ip-geolocation/ip-geolocation.webp"
images: ["/images/network/ip-geolocation/ip-geolocation.webp"]
tags:
  - network
  - ip
  - geolocation
categories:
  - case
---

# 현상

약 10ms 응답속도가 예상되는 API에 500~700ms의 응답속도가 발생했다.

# 원인

![](/images/network/ip-geolocation/ipapi-latency.png)

해당 비즈니스 로직에는 국가별로 다른 정책을 적용하기 위해 IP로 국가 정보를 얻는 작업을 가장 먼저 하고 있다.
국가 정보를 얻는 곳은 IP-API라는 유료 API 서비스와 IPInfoDB를 사용하고 있다.
대략적인 코드는 다음과 같다.

```java
@Cacheable(value = CacheName.IPAPI_COUNTRY_CODE, key = "#ipAddress")
public Geolocation findIsoCountryCode(final String ipAddress) {
    if (isPrivate(ipAddress)) {
        return Geolocation.korea();
    }
    return ipapiFeignClient.findGeolocationByIpAddress(ipAddress, IPAPI_ACCESS_KEY);
}
```

문제는 API가 아무리 빨라도 해당 IP Geolocation 서비스에서 응답받는 데에 평균 약 500ms 정도 소요되었다는 것이다.

# 해결

이를 해결하기 위해 캐싱도 해봤지만 처음 접속한 IP의 경우 조회가 발생할 수 밖에 없었고,
결정적으로 이렇게 처음 접속한 IP가 매우 많았다(월 130만 건 정도)는 것이다.

이 문제는 생각보다 간단하게 해결할 수 있다.
CDN을 사용할 경우 CDN에서 제공하는 헤더에서 위치 정보를 얻을 수 있다.

- Akamai의 EdgeScape 기능을 활성화하면 `X-Akamai-Edgescape` 헤더로
  [국가 코드 2자리(ISO 3166-1 alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)를 확인할 수 있다.
- [CloudFlare의 문서](https://developers.cloudflare.com/network/ip-geolocation/)를 확인해보면
  관련 기능을 활성화 했을 경우 `CF-IPCountry` 헤더로 확인할 수 있다고 한다.
- Amazon CloudFront도 `CloudFront-Viewer-Country` 헤더로 확인할 수 있다고 한다.

이 헤더를 활용하면 별도 서비스를 조회할 필요가 없기 때문에 응답 속도를 줄일 수 있었다.

## 구현 방법 (Spring Framework)

```java
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface GeoLocation {
}
```

```java
@Aspect
@Component
@RequiredArgsConstructor
public class GeoLocationAspect {
    private final HttpServletRequest request;
    private final GeoLocationService service;
    /**
     * <code>@annotation(GeoLocation)</code>와 같은 방식은
     * <code>@GeoLocation</code> 애노테이션이 붙은 메서드에만 적용됩니다.
     */
    @Pointcut("@annotation(org.springframework.web.bind.annotation.GetMapping) || "
            + "@annotation(org.springframework.web.bind.annotation.PostMapping) || "
            + "@annotation(org.springframework.web.bind.annotation.RequestMapping)")
    public void mappingAnnotations() {
    }
    @Around("mappingAnnotations()")
    public Object injectGeoLocation(ProceedingJoinPoint joinPoint) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Object[] args = joinPoint.getArgs();
        Parameter[] parameters = method.getParameters();
        for (int i = 0; i < parameters.length; i++) {
            if (parameters[i].isAnnotationPresent(GeoLocation.class)) {
                Location geoLocation = getGeoLocationFromRequest();
                // @GeoLocation 파라미터에 위치 정보를 주입합니다.
                args[i] = geoLocation;
            }
        }
        // 메서드 호출을 진행합니다.
        return joinPoint.proceed(args);
    }
    /**
     * CDN, ipapi, IPInfoDB 순으로 접속 국가 코드 조회
     *
     * @return Geolocation
     */
    private Location getGeoLocationFromRequest() {
        return service.findLocation(request);
    }
}
```

```java
@GetMapping
public Response<Items> control(
        @GeoLocation final Location location,
        @AuthenticationPrincipal final PrincipalDetailDto user,
        @RequestBody @Valid final RequestDto requestDto
) {
    log.debug(location);
    return success(service.process(requestDto));
}
```

# 덤으로 얻은 정확성?

추가로 해결되었던 점은 정확성이었다.

현재 서비스에서 아제르바이잔 이용자에게만 적용되는 정책이 있었는데 실제 이용자에게서 본인에게만 적용되지 않는다고 클레임이 들어왔다.
확인해보니 ipapi에서 정확하지 않은 Geolocation 정보가 응답되고 있었다. 이는 ipapi만의 문제가 아니었다.

![](/images/network/ip-geolocation/iplocation-inaccuracy.png)

*네덜란드이거나 아제르바이잔이거나 | [iplocation.io](https://iplocation.io/)*

![](/images/network/ip-geolocation/ipapi-inaccuracy.png)

*파나마 공화국이다 | [ipapi](https://ipapi.com/)*

우리는 2024년 4월 12일 ipapi에 문의했지만 데이터 공급자(Data Provider)에 의해 업데이트 될 것이라는 답변만 받았었다.
하지만 4달이 지난 현재(8월 29일)에도 업데이트되지 않았다.

그렇다면 CDN Provider는 믿을 수 있을까?
우리가 사용한 CDN은 Akamai이고, Akamai에서 제공하는 **Akamai EdgeScape Methodology** 문서(Akamai Control >
Download Center > Core Features > EdgeScape)를 보면 신뢰도가 높아보였다.

> \<Akamai EdgeScape Methodology\> - "How Does Akamai Know the Location of an IP Address?" 섹션 발췌 (ChatGPT를 통한 번역)
> - **공공 등록 데이터** 우리는 다양한 공공 인터넷 등록 기관과 ISP에 등록된 IP 블록에 대한 지리적 정보를 획득합니다. 이 정보는 데이터베이스의 기본 계층을 형성합니다. 이는 공개된 블록 주소에 대한 정보이므로, 다른 데이터 소스를 분석할 때 가장 신뢰도가 낮은 데이터로 간주합니다.
> - **호스트 이름 패턴 매칭** 인터넷상의 많은 기계(라우터, 서버, POP, 최종 사용자 기계 등)는 호스트 이름(역방향 DNS 항목)과 연결되어 있습니다. 많은 경우, 이 호스트 이름에는 기계의 위치를 암시하는 지리적 정보가 포함되어 있습니다. 다양한 네트워크와 ISP의 호스트 이름을 분석하여 이러한 이름에 내포된 지리적 정보를 추출할 수 있는 패턴 데이터베이스를 구축하고 지속적으로 추가하고 있습니다.
> - **알려진 위치** Akamai는 전 세계에 분산된 광범위한 서버 네트워크를 보유하고 있어 인근 기계의 위치를 결정할 때 데이터 포인트로 활용할 수 있습니다. 또한, 트래픽을 효율적으로 제공하기 위해 네트워크 및 고객과의 관계를 통해 서버 위치에 대한 유용한 정보를 얻습니다.
> - **능동 측정** Akamai의 광범위한 고객 기반 덕분에, 우리는 특정 시간에 인터넷상의 많은 "활성" 최종 사용자 IP를 알고 있습니다. 우리는 이러한 활성 IP에 글로벌 분산 네트워크의 다양한 지점에서 traceroute와 ping을 수행합니다. 또한 라우터와 인프라 서버와 같은 비최종 사용자 IP에 대해 제한된 수의 traceroute와 ping을 수행합니다.
>   추적을 분석할 때, 위에서 설명한 호스트 이름 패턴 매칭을 통해 결정된 기계의 위치와 인터넷 등록 기관에서 제공된 지리적 정보를 사용하여 추적된 IP의 위치를 결정합니다. 추가로, 추적에 포함된 지연 시간 정보와 라우터에 대한 ping을 통해 수집된 지연 시간 정보를 사용하여 잘못된 데이터를 걸러내고 선택한 위치의 정확성을 높입니다.
> - **경쟁사와의 차별화** 우리의 경쟁사도 일부 동일한 방법을 사용하여 데이터베이스를 생성할 가능성이 있지만, 우리의 컨텐츠 전송 네트워크(CDN)의 방대한 규모와 범위, 그리고 이를 통해 제공되는 정보가 중요한 차별화 요소입니다. 또한, 네트워크 제공업체와의 관계, 방대한 고객 기반, 그리고 인터넷과 그 토폴로지에 대한 통찰력을 바탕으로 Akamai는 업계에서 독보적인 위치를 차지하고 있습니다.

## 제로 트러스트!

하지만 하루만에 문제가 발생했다.
간헐적으로 한국에서 접속한 사용자가 미국에서 접속한 것으로 전달되었다.
확인해보니 Akamai에서 전달하는 `True-Client-IP` 헤더는 실제 한국 사용자 IP였고,
`X-Akamai-EdgeScape` 헤더에는 미국(country_code=US),
`X-Forwarded-For` 헤더[^1]는 Akamai 엣지 서버의 IP가 전달되고 있었다.
이 경우 `True-Client-IP`와 `X-Forwarded-For` 헤더가 달랐다.
그래서 **`True-Client-IP`와 `X-Forwarded-For` 헤더가 가리키는 IP가 서로 다를 경우에는 다른 서비스에서 Geolocation을 조회하고 캐시하도록 설정했다.**
(CDN -> ipapi -> IPInfoDB 순)

추가로 Apache에서 `RemoteIPHeader X-Forwarded-For` 설정이 있으면
프록시 서버들의 IP는 모두 빠지고 Client IP만 남는다.[^2]
그래서 해당 설정을 빼고 `True-Client-IP`를 확인한다.

*다만 이 설정을 변경하면 IP를 활용하는 비즈니스 로직에 영향을 줄 수 있으니 영향도를 고려해야 한다.*

```xml
<VirtualHost *:443>
    ServerName www.example.com
    ProxyRequests Off
    ProxyVia Off
    ProxyPreserveHost On
    # RemoteIPHeader X-Forwarded-For
    ProxyAddHeaders On
</VirtualHost>
```

# 참조

- True-Client-IP 헤더
  - [Akamai | `True-Client-IP` 설정](https://techdocs.akamai.com/property-mgr/docs/origin-server#true-client-ip-header)
  - [Cloudflare | `True-Client-IP` 설정](https://developers.cloudflare.com/network/true-client-ip-header/)
  - [AWS CloudFront | `True-Client-IP` 헤더 추가하기](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/example-function-add-true-client-ip-header.html)

[^1]: [X-Forwarded-For | mdn web docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For)
[^2]: [Apache Module mod_remoteip](https://httpd.apache.org/docs/current/mod/mod_remoteip.html#remoteipheader)
