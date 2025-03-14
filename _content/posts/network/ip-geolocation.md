---
date: 2024-08-29T22:38:00+09:00
lastmod: 2024-08-29T22:38:00+09:00
title: "IP로 지리적 위치(Geolocation) 찾기"
description: "CDN에서 위치 정보를 얻는 방법"
images: ["/images/network/ip-geolocation/ip-geolocation.webp"]
tags:
  - network
  - ip
  - geolocation
categories:
  - blog
---

# 현상

약 10ms 응답속도가 예상되는 API에 500~700ms의 응답속도가 발생했습니다.

# 원인

![ipapi Latency](/images/network/ip-geolocation/ipapi-latency.png)

해당 API에서는 국가별로 다른 정책을 적용하기 위해 IP로 국가 정보[^1]를 조회하는 기능이 가장 먼저 수행됩니다.
국가 정보의 출처는 ipapi라는 유료 API 서비스와 IPInfoDB라는 무료 서비스입니다.
대략적인 코드는 다음과 같습니다.

```java
@Cacheable(value = CacheName.IPAPI_COUNTRY_CODE, key = "#ipAddress")
public Geolocation findIsoCountryCode(final String ipAddress) {
    if (isPrivate(ipAddress)) {
        return Geolocation.korea();
    }
    var ipapi = ipapiFeignClient.findGeolocationByIpAddress(ipAddress, IPAPI_ACCESS_KEY);
    if (ipapi != null) {
        return Geolocation.from(ipapi);
    }
    var ipInfoDB = ipInfoDBFeignClient.findGeolocationByIpAddress(ipAddress, IPINFODB_ACCESS_KEY);
    if (ipInfoDB != null) {
        return Geolocation.from(ipInfoDB);
    }
    return Geolocation.korea();
}
```

문제는 API가 아무리 빨라도 해당 IP Geolocation 서비스에서 응답받는 데에 평균 약 500ms 정도 소요되었다는 것입니다.

# 해결

이를 해결하기 위해 캐싱도 해봤지만 처음 접속한 IP의 경우 조회가 발생할 수 밖에 없었고,
결정적으로 이렇게 처음 접속한 IP가 매우 많았다(약 130만 건/월)는 것입니다.

이 문제는 생각보다 간단하게 해결할 수 있었습니다.
CDN을 사용할 경우 CDN에서 제공하는 헤더에서 위치 정보를 얻을 수 있는데,
이 헤더를 활용하면 별도 서비스를 조회할 필요가 없기 때문에 응답 속도를 줄일 수 있었습니다.

- **Akamai**는 EdgeScape 기능을 활성화하면 `X-Akamai-Edgescape` 헤더로 확인할 수 있습니다.[^2]
- **CloudFlare**는 관련 기능을 활성화 했을 경우 `CF-IPCountry` 헤더로 확인할 수 있다고 합니다.[^3]
- **Amazon CloudFront**는 `CloudFront-Viewer-Country` 헤더로 확인할 수 있다고 합니다.[^4]

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

추가로 해결되었던 점은 정확성이었습니다.

현재 서비스에서 아제르바이잔 이용자에게만 적용되는 정책이 있었는데 실제 이용자에게서 본인에게만 적용되지 않는다고 클레임이 들어왔습니다.
확인해보니 ipapi에서 정확하지 않은 Geolocation 정보가 응답되고 있었습니다.
이는 ipapi만의 문제가 아니었습니다.

![iplocation inaccuracy](/images/network/ip-geolocation/iplocation-inaccuracy.png)

*네덜란드이거나 아제르바이잔이거나 | [iplocation.io](https://iplocation.io/)*

![ipapi inaccuracy](/images/network/ip-geolocation/ipapi-inaccuracy.png)

*파나마 공화국이었던 | [ipapi](https://ipapi.com/)*

우리는 2024년 4월 12일 ipapi에 문의했지만 데이터 공급자(Data Provider)에 의해 업데이트 될 것이라는 답변만 받았었습니다.
하지만 4개월이 지난 현재(8월 29일)에도 업데이트되지 않았습니다.

그렇다면 CDN Provider는 믿을 수 있을까요?
저희 서비스에서 사용하는 Akamai 문서를 보면 신뢰도가 높아보였습니다.

> "How Does Akamai Know the Location of an IP Address?" | \<Akamai EdgeScape Methodology\> 발췌
>
> (Akamai Control > Download Center > Core Features > EdgeScape)
>
> - **Public Registry Data**
>   We obtain geographic information for the IP blocks registered with the various public Internet registries and ISPs. This information forms the base layer of the database.
>   As this is public information registered for blocks of addresses, we trust this data the least when analyzing the different sources of data.
> - **Hostname Pattern Matching**
>   Many machines on the Internet (routers, servers, POPs, and even end-user machines) have a hostname (reverse DNS entry) associated with them.
>   In many cases, these hostnames contain geographic information hinting at the location of that machine.
>   By analyzing hostnames from different networks and ISPs, we have built up, and continue to add to,
>   a database of patterns that allows us to extract the geographic information embedded in these names.
>   It also allows us to extrapolate the location of other machines on the Internet,
>   by giving us data points that can be used when tracing to other IPs.
> - **Known Locations**
>   Akamai has an extensive network of servers distributed across the globe, which act as data points when determining the location of machines nearby.
>   We also have relationships with networks and customers all over the world.
>   In order to serve their traffic efficiently, we sometimes get useful information from them regarding the location of their servers,
>   which we can also use as data points in creating our geographic database.
> - **Active Measurement**
>   Due to Akamai's extensive customer base, we have the unique ability to know at any given time a large fraction of "active" end-user IPs on the net.
>   We then perform traceroutes and pings from various points on our globally distributed network to these active IPs.
>   We also perform a reduced number of traces and pings to IPs in the non end-user space, such as routers and infrastructure servers.\
>\
> When analyzing the traces, we use the location of machines determined using the Hostname pattern matching described above
> and the geographic information from the Internet registries to determine the location of the IP traced to.
> In addition, we use the latency information contained within the trace and the latency information gathered from pinging routers,
> along with the limitations imposed by speed-of-light bounds,
> in order to weed out bad data and increase the probability of the location we choose being correct.

## 제로 트러스트!

하지만 하루만에 문제가 발생했습니다.
간헐적으로 한국에서 접속한 사용자가 미국에서 접속한 것으로 전달되었습니다.

확인해보니 Akamai에서 전달하는 `True-Client-IP` 헤더는 실제 한국 사용자 IP였고,
`X-Akamai-EdgeScape` 헤더에는 미국(country_code=US),
`X-Forwarded-For` 헤더[^5]는 Akamai 엣지 서버의 IP가 전달되고 있었습니다.
이 경우 `True-Client-IP`와 `X-Forwarded-For` 헤더가 달랐습니다.
그래서 **`True-Client-IP`와 `X-Forwarded-For` 헤더가 가리키는 IP가 서로 다를 경우에는 다른 서비스에서 Geolocation을 조회하고 캐싱하도록 설정했습니다.**
(CDN -> ipapi -> IPInfoDB 순)

추가로 Apache에서 `RemoteIPHeader X-Forwarded-For` 설정이 있으면
프록시 서버들의 IP는 모두 빠지고 Client IP만 남습니다.[^6]
그래서 해당 설정을 제거했습니다.

*다만 이 설정을 변경하면 IP를 활용하는 비즈니스 로직에 영향을 줄 수 있으니 영향도를 고려해야 합니다.*

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

[^1]: 조회하는 정보는 [국가 코드 2자리(ISO 3166-1 alpha-2)](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)입니다.
[^2]: [Content Targeting (EdgeScape)](https://techdocs.akamai.com/property-mgr/docs/content-tgting) | Akamai
[^3]: [IP geolocation](https://developers.cloudflare.com/network/ip-geolocation/) | Cloudflare
[^4]: [Add CloudFront request headers](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/adding-cloudfront-headers.html) | Amazon CloudFront
[^5]: [X-Forwarded-For](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For) | mdn web docs
[^6]: [Apache Module mod_remoteip](https://httpd.apache.org/docs/current/mod/mod_remoteip.html#remoteipheader) | Apache
