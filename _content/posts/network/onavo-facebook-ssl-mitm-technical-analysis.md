---
draft: false
date: 2024-09-12T00:17:00+09:00
lastmod: 2024-09-12T00:17:00+09:00
title: "Facebook은 경쟁사의 암호화된 모바일 앱 트래픽을 어떻게 가로챘을까?"
description: "Onavo Protect, SSL Bump 그리고 Certificate Pinning"
featured_image: "/images/network/onavo-facebook-ssl-mitm-technical-analysis/fbdark-1.webp"
images: ["/images/network/onavo-facebook-ssl-mitm-technical-analysis/fbdark-1.webp"]
tags:
  - network
  - security
  - mitm
categories:
  - translate
---

- [How did Facebook intercept their competitor's encrypted mobile app traffic?](https://doubleagent.net/onavo-facebook-ssl-mitm-technical-analysis/)
  | [HaxRob](https://x.com/haxrob), 2024년 4월 14일
- 저자의 허락을 받고 번역했습니다.
- 각주는 역주입니다.

---

이 글은 페이스북(Facebook) 집단 소송에서 밝혀진 정보를 바탕으로 한 기술 조사입니다.
페이스북은 경쟁사의 정보를 얻기 위해 Onavo Protect 앱을 실행 중인 사용자 기기에서 암호화된 트래픽을 도청했었다는 이유로 재판이 진행 중입니다.

![How did Facebook intercept their competitor's encrypted mobile app traffic?](/images/network/onavo-facebook-ssl-mitm-technical-analysis/fbdark-1.webp)

*2024년 7월 28일 - 👋Hello [Hackernews](https://news.ycombinator.com/item?id=41090304)!*

현재 메타(Meta)를 상대로 한 집단 소송이 진행 중이며,
법원 문서에 따르면* 메타가 [도청법(Wiretap Act)](https://en.wikipedia.org/wiki/Electronic_Communications_Privacy_Act)을 위반했을 가능성이 있다고 언급되어 있습니다.
이 글에서의 분석은 [법원 문서](https://www.documentcloud.org/documents/24520332-merged-fb) 내용과
안드로이드(Android) 용 Onavo Protect 앱 패키지의 아카이브된 버전을 리버스 엔지니어링한 결과를 바탕으로 하고 있습니다.

법원 문서에 따르면, 페이스북이 사용자의 암호화된 HTTPS 트래픽을 가로채기 위해
[중간자 공격(MITM)](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)으로 간주될 수 있는 방법을 사용했다고 합니다.
페이스북은 이 기술을 "ssl bump"라고 불렀으며,
이는 [Squid 캐싱](https://www.squid-cache.org/) 프록시 소프트웨어의 transparent proxy [기능 (ssl_bump)](https://www.squid-cache.org/Doc/config/ssl_bump/)에서 유래된 이름입니다.
해당 기술은 스냅챗(Snapchat), 유튜브(YouTube), 아마존(Amazon)의 특정 도메인을 (추정컨대) 복호화하는 데 사용되었다고 합니다.
이 사건에 대한 추가 배경 정보는 최근 [TechCrunch](https://techcrunch.com/2024/03/26/facebook-secret-project-snooped-snapchat-user-traffic/) 기사를 읽어볼 것을 권장합니다.

> [2024-07-28] - 이는 [2019년에 TechCrunch가 공개한](https://techcrunch.com/2019/01/29/facebook-project-atlas/) 내용과 다릅니다.
> 당시 페이스북은 10대 청소년들에게 사용 습관 데이터를 수집하기 위해 돈을 지불했고,
> 그 결과 Onavo 앱은 앱 스토어에서 삭제되고 [벌금이 부과되었습니다](https://www.accc.gov.au/media-release/20m-penalty-for-meta-companies-for-conduct-liable-to-mislead-consumers-about-use-of-their-data).
> 이번에 새롭게 밝혀진 중간자 공격(MITM) 정보와 관련하여, 현재 명확하지 않은 점은 모든 앱 사용자의 트래픽이 "가로채기" 되었는지, 아니면 일부 사용자만 해당되었는지입니다.

> *한 HN 사용자는 다음과 같이 [명확히 합니다](https://news.ycombinator.com/item?id=41091505&ref=doubleagent.net).\
> \
> "이것은 도청법 위반 소송이 아닙니다. 독점 금지 소송으로, 청구 내용은 모두 셔먼법[^1] 위반에 관한 것입니다.
> 원고 측 변호사들이 자료 조사 과정에서 페이스북이 도청법을 위반했을 가능성이 있다는 증거를 _우연히_ 발견했습니다."

![Case 3:20-cv-08570-JD Document 735 Filed 03/23/24 Page 1](https://doubleagent.net/content/images/2024/07/image-1.png)

*\*Case 3:20-cv-08570-JD Document 735 Filed 03/23/24 Page 1*

> 이 글은 제한적이고 부분적인 정보로 인해 일부 사실이 부정확하거나 불완전할 수 있습니다.
> 따라서 수정이 필요하거나 새로운 사실이 발견될 경우 이 글은 업데이트될 수 있습니다.
> 새로운 콘텐츠를 받아보고 싶으시면 [저자의 블로그](https://doubleagent.net/onavo-facebook-ssl-mitm-technical-analysis/)를 구독하시거나
> [저자의 X](https://twitter.com/haxrob)를 팔로우하세요.

- [개요](#개요)
- [동기](#동기)
- [분석](#분석)
  - [CA 인증서](#ca-인증서)
  - [핵심 질문으로 돌아가서](#핵심-질문으로-돌아가서)
- [또 무엇이 있을까요?](#또-무엇이-있을까요)
- [마무리](#마무리)

# 개요

- [1,000만 건](https://www.androidrank.org/application/onavo_protect_from_facebook/com.onavo.spaceship)이 넘는
  안드로이드 설치를 기록한 [Onavo Protect 안드로이드 앱](https://apkpure.com/onavo-protect-from-facebook/com.onavo.spaceship)에는
  기기의 사용자 신뢰 저장소(user trust store)에 "Facebook Research"에서 발급한 CA(인증 기관) 인증서를 설치하도록 유도하는 코드가 포함되어 있었습니다.
  이 인증서는 페이스북이 TLS 트래픽을 복호화하기 위해 필요했습니다.
- 2016년에 배포된 일부 구 버전 앱에는 embedded assets으로 Facebook Research CA 인증서가 포함되어 있습니다.
  그 중 하나의 인증서는 2027년까지 유효합니다.
  법원 문서의 자료 조사 내용에 따르면, 인증서는 "서버에서 생성되어 기기로 전송된다"고 명시되어 있습니다.
- "ssl bump" 기능이 Protect 앱에 도입된 직후, 최신 버전의 안드로이드가 출시되었으며,
  이 버전에는 향상된 보안 제어 기능이 포함되어 있어 이 방법이 최신 운영체제를 사용하는 기기에서는 더 이상 작동하지 않게 되었습니다.
- 이전 스냅챗 앱을 검토한 결과, 해당 앱의 분석 도메인(analytics domain)은 인증서 고정[^2]을 적용하지 않았음을 알 수 있었습니다.
  이는 중간자 공격(MITM) 또는 "ssl bumping"이 앞서 설명한 대로 작동했을 가능성이 있음을 의미합니다.
- 사용자가 부여한 권한을 악용하여 다른 앱의 사용 통계를 수집하는 핵심 기능 외에도,
  구독자 [IMSI](https://en.wikipedia.org/wiki/International_mobile_subscriber_identity)와 같은
  민감한 데이터를 수집하는 의심스러운 기능이 추가로 있는 것으로 보입니다.

아마도 구성은 다음 그림과 비슷했을 것입니다.

![An interpretation of FB's setup based on court documents and app analysis](https://doubleagent.net/content/images/2024/04/fb1-3-1.png)

신뢰할 수 있는 인증서가 기기에 설치되어 있으며,
디바이스의 모든 트래픽이 VPN을 통해 페이스북이 관리하는 인프라로 전송되고,
트래픽은 'ssl bump' 기능이 설정된 traceparent proxy로 구성된 Squid 캐싱 프록시로 리다이렉션됩니다.
문서에 따르면 스냅챗, 아마존, 유튜브에 속한 다양한 도메인들이 관심 대상이었습니다.
다른 사용자 트래픽이 가로채졌는지 아니면 단순히 프록시 처리만 되었는지는 알 수 없습니다.
이러한 정보는 아카이브된 Onavo Protect 앱을 살펴봐도 얻을 수 없으며,
현재로서는 공개된 법원 문서에 의존할 수밖에 없습니다.

시간이 지나면서 transparent TLS 프록시를 사용하는 그들의 전략은
안드로이드의 보안 제어(security controls)가 개선됨에 따라 성공률이 감소하고 있었습니다.
또한 인증서 고정의 도입도 문제가 된다고 했습니다.
이에 대한 대안으로 페이스북은 접근성(Accessibility) API를 사용하는 방안을 고려하고 있었습니다.

![Page 3 - Case 3:20-cv-08570-JD Document 736](https://doubleagent.net/content/images/2024/04/image-14.png)

*Page 3 - Case 3:20-cv-08570-JD Document 736*

구글(Google)이 자사의 운영 체제에서 접근성 기능 사용에 대해 다음과 같이 말하고 있습니다.

> "장애가 있는 사람들이 기기에 접근하거나 그들의 장애로 인한 문제를 해결하는 데 도움을 주기 위해 설계된 서비스만이 접근성 도구로 선언될 자격이 있습니다."

장애가 있는 사람들을 지원하기 위해 설계된 기능을 경쟁 우위를 위해 악용하려는 기업이 있다는 것을 짐작할 수 있습니다.
Android 접근성 기능의 남용은 주로
[뱅킹 멀웨어](https://blog.pradeo.com/accessibility-services-mobile-analysis-malware)와 같은 악성 애플리케이션에 의해 발생하는 것으로 알려져 있습니다.

# 동기

마크 주커버그(Mark Zuckerberg)는 스냅챗에서 "*신뢰할 수 있는 분석*"의 필요성을 언급합니다.

![Mark Zuckerberg PX2255](https://doubleagent.net/content/images/2024/04/image-4.png)

해결책은? "*특정 하위 도메인의 트래픽을 가로채기 위해 iOS 및 Android에 설치할 수 있는 키트*".

![Danny Ferrante](https://doubleagent.net/content/images/size/w1000/2024/04/image-6.png)

제 생각에는 특정 도메인의 트래픽을 가로채기 위해 Onavo Protect VPN 앱을 활용하는 것 외에도
핵심 기술을 리브랜딩하여 다른 애플리케이션에 배포하려는 의도가 있었습니다.
페이스북은 2013년에 약 1억 2천만 달러에 Onavo를 [인수했으며](https://techcrunch.com/2013/10/13/facebook-buys-mobile-analytics-company-onavo-and-finally-gets-its-office-in-israel/)
이 기술을 잘 활용할 필요가 있었습니다.
이 가격은 사람들이 사용하는 휴대폰과 태블릿에서 경쟁사 정보를 얻는 능력에 대해 그들이 얼마나 높은 가치를 두었는지 명확하게 보여줍니다.

iOS 버전에 대한 [이전 연구](https://medium.com/@chronic_9612/notes-on-analytics-and-tracking-in-onavo-protect-for-ios-904bdff346c0)에서는
Onavo VPN 앱이 아이폰(iPhone)에서 일부 사용 정보를 수집하고 있었음을 지적하고 있습니다.
안드로이드에서는 이 앱이 사용자에게 앱 데이터 사용량을 보여준다는 명목으로 부여된 권한을 활용하여
사용자 기기에서 훨씬 더 세밀한 통계를 수집하고 있음을 확인할 수 있습니다(아래에 포함된 영상에서 이 모습이 어떻게 나타났는지 확인할 수 있습니다).
그러나 이것만으로는 충분하지 않았고, 페이스북은 한 걸음 더 나아가
특정 경쟁사의 분석 도메인으로 향하는 암호화된 트래픽을 가로채어 "**인앱 액션(in-app actions)**"에 대한 데이터를 얻으려 했습니다.

그들이 해야 할 일은 사용자가 사용자 휴대폰의 신뢰 저장소(trust store)에 커스텀 인증서를 설치하도록
(그리고 특정 안드로이드 버전을 사용)하는 것뿐이었습니다.

> 도청 정보는 새로운 것이며, 이전에 발생한 사건과 혼동해서는 안 됩니다.\
>\
> [ACCC](https://www.accc.gov.au/media-release/20m-penalty-for-meta-companies-for-conduct-liable-to-mislead-consumers-about-use-of-their-data)에 따르면,
> 2023년에 페이스북의 두 자회사는 호주 연방법원으로부터
> "호주 소비자법을 위반하여 오해를 일으킬 수 있는 행위를 한" 혐의로 총 2천만 호주달러의 벌금이 부과되었습니다.\
>\
> 페이스북은 2019년에 Onavo를 폐쇄했는데, 이는 청소년들이 앱을 사용하도록 유도하여
> 그들의 활동을 추적하고 있었다는 [조사](https://techcrunch.com/2019/01/29/facebook-project-atlas/)가 밝혀졌기 때문입니다.
> 또한 그해 애플(Apple)은 [페이스북의 개발자 프로그램 인증서를 철회하는](https://web.archive.org/web/20220609072355/https://www.vox.com/2019/1/30/18203231/apple-banning-facebook-research-app)
> 강력한 조치를 취해 분명한 메시지를 전달했습니다.\
>\
> 서비스 종료된 앱이지만, 이 글에서 제공하는 기술적 인사이트를 얻을 수 있는 오래된 버전의 앱을 찾을 수 있었습니다.

# 분석

최종 사용자 디바이스의 웹사이트와 애플리케이션은 디바이스 내 신뢰 저장소에 저장된 public 인증서를 통해 HTTPS/TLS를 사용하는 원격 웹사이트나 서버를 신뢰합니다.
이러한 "인증 기관(CA)" 인증서는 애플리케이션이 신뢰할 수 있는 상대방과 통신하고 있음을 확인해 주는 "신뢰 앵커(trust anchor)" 역할을 합니다.
이 인증서는 일반적으로 운영 체제에 의해 배포되고 저장됩니다.
신뢰 저장소에 자체 서명한 인증서(self-signed certificate)를 추가하면 암호화된 TLS 트래픽을 가로챌 수 있습니다.
기업은 직원의 디바이스에서 나가는 트래픽(outbound traffic)을 검사하기 위해 이 방법을 사용할 수 있으며, 보안 테스터들도 자신의 기기에서 이를 활용할 수 있습니다.
이러한 것들은 모두 적법한 작업입니다.
여기서 중요한 질문은 페이스북이 한 행위가 적법했냐는 것입니다.

> 페이스북이 도청을 위해 사용했다고 알려진 소프트웨어의 문서에 다음과 같은 경고가 포함되어 있다는 점은 약간 아이러니합니다.\
>\
> "*HTTPS는 사용자에게 개인정보보호 및 보안을 제공하기 위해 설계되었습니다.
> 사용자 동의나 인지 없이 HTTPS 터널을 복호화하는 것은 윤리 규범을 위반할 수 있으며,
> 관할 지역에서 불법일 수 있습니다.*"

아이폰의 iOS와 달리 구글은 대부분의 모바일 애플리케이션에서 신뢰할 수 있는 CA 인증서를 설치하기가 매우 어렵도록 수많은 변경 사항을 적용했습니다.
2020년 9월에 출시된 안드로이드 11에서는 앱이 사용자에게 인증서를 설치하라는 메시지를 표시하는 메커니즘을 완전히 차단했습니다.
그리고 어떤 애플리케이션도 기본적으로 사용자 저장소에 있는 인증서를 신뢰하지 않습니다.

> 사람들은 "*인증서 고정(Certificate Pinning)이 뭐죠? 이건 MITM을 막을 수 없었을까요?*"라고 질문합니다.\
> \
> 나중에 살펴보겠지만, 당시 스냅챗 앱은 분석 도메인에 대한 인증서 고정을 구현하지 않았습니다.
> 이는 다른 앱 도메인의 경우에도 마찬가지일 것입니다.
> 따라서 페이스북은 경쟁사의 이러한 기술적 제한/실수를 이용한 것으로 보입니다.

현재는 2016년부터 2019년까지 페이스북이 했던 일을 하는 것은 기술적으로 불가능합니다.
하지만 그들은 어떻게 해냈을까요?
다행히도 우리는 안드로이드와 Play 스토어 생태계를 통해 오래된 안드로이드 앱 패키지를 종종 찾을 수 있습니다.

먼저 테스트 단말기에 Onavo 앱을 설치하여 사용자가 앱과 어떻게 상호 작용하는지 확인했습니다.
VPN 연결이 작동하지 않고 실제 백엔드 서비스가 중단된 상태입니다.
하지만 이 애플리케이션이 사용자에게 여러 권한을 강제로 허용하도록 어떻게 강제하는지 엿볼 수 있었습니다:

<video src="https://doubleagent.net/content/media/2024/04/zszPzD8NSHAFb9W1.mp4" width="480" height="852" controls></video>

여기서 우리가 확인할 수 있는 것은 사용자 '보호'를 제공한다는 구실로 요구하는 2가지 특정 권한이 문제가 된다는 점입니다.

- 다른 앱 위에 표시 (Display over other apps)
- 과거 및 삭제된 앱 사용 내역에 액세스 (Access past and deleted app usage)

> *"앱에서 사용하는 모바일 데이터의 양을 표시하려면 이 권한이 필요합니다."*

그들이 설명하지 않은 것은 이 기능이 앱을 설치한 사용자를 위한 것이 아니라 실제로는 Onavo/Facebook을 위한 것이라는 점입니다.
이러한 정보는 매우 가치가 있으며, 이는 페이스북이 인수에 지불한 1억 2천만 달러라는 금액만 보더라도 알 수 있습니다.

![Onavo App Permissions](https://pbs.twimg.com/media/GJpCkIEbkAAsckm?format=jpg&name=small)

안드로이드 매니페스트(manifest)에는 `uses-permission` 지시어인 `android.permission.PACKAGE_USAGE_STATS`가 포함되어 있으며,
이는 위 스크린샷에서 우리가 동의한 권한입니다.

![PACKAGE_USAGE_STATS](https://pbs.twimg.com/media/GJptvfla8AA0rVZ?format=png&name=medium)

"애플리케이션 통계" 기능(원래의 핵심 기능으로 추정됨)을 계속 살펴보면,
모바일 기기의 로컬 데이터베이스 스키마를 덤프하면 기기가 실제로 수집한 데이터를 정확히 파악할 수 있습니다.

![collecting on the device](https://pbs.twimg.com/media/GJpyTakbIAAeD_A?format=png&name=large)

대개 다른 애플리케이션의 사용 통계와 네트워크 트래픽 사용량만 얻을 수 있었던 것으로 보입니다.
이것은 여전히 다소 높은 수준의 통계이며, 법원 문서의 이메일 중 하나에서 암시된 것처럼 마크 주커버그가 원했던 세부 사항에는 미치지 못했습니다.
반면에 다양한 경쟁사의 분석 도메인으로 향하는 실제 암호화된 트래픽을 가로챌 수 있다면 목적을 달성할 수 있었을 것입니다.
이를 위해 페이스북은 어떻게든 기기에 CA 인증서를 설치해야 했습니다.

하지만 인증서 설치를 요청하는 메시지(prompt)는 나타나지 않았습니다.
이는 VPN이 원격 서비스에 성공적으로 연결되지 않았기 때문이며, 이는 전제 조건인 것으로 보입니다.
시간이 나거나 관심이 생기면 인증서 설치 메시지를 어떻게 활성화할 수 있는지 다시 확인해볼 생각입니다.

![Connections timing out, and a tcpdump shows that all traffic from the device is dropped after the VPN connection is initiated](https://doubleagent.net/content/images/size/w1000/2024/04/GJo--s8aQAAYwtL.png)

## CA 인증서

앱을 디컴파일해보니 해당 기능이 존재하는 것을 확인할 수 있었습니다.
다음 이미지에서 하이라이트된 메서드는 `KeyChain.createInstallIntent()`를 호출하여 인증서를 설치합니다.
여기서 "Facebook Research"라는 이름으로 사용자에게 권한을 요청하는 팝업이 나타날 것입니다.

![KeyChain.createInstallIntent](https://doubleagent.net/content/images/2024/04/GJpP7rmaAAAQDKI.png)

`KeyChain.createInstallIntent()`는 Android 7(Nougat)에서 [더 이상 작동하지 않게 되었습니다](https://commonsware.com/R/pages/chap-security-004.html).
사용자가 인증서를 수동으로 설치해야 합니다.
이제 Facebook의 CA 인증서를 앱 내에서 직접 설치하는 것은 불가능해졌습니다.

Android 7에서 주목할 만한 또 다른 변경 사항은 [Android 문서](https://developer.android.com/privacy-and-security/security-config)에 따르면 다음과 같습니다(강조는 필자).

> *기본적으로 모든 앱의 보안 연결(TLS 및 HTTPS와 같은 프로토콜 사용)은 사전 설치된 시스템 CA를 신뢰하며, **Android 6.0(API 레벨 23) 이하를 대상으로 하는 앱은 기본적으로 사용자가 추가한 CA 저장소도 신뢰합니다**.*

즉, Android Marshmallow(Android 6)와 그 이전 버전에서는 다른 앱들이 사용자 저장소에 있는 인증서를 신뢰했지만,
2016년 8월 22일에 출시된 Android 7부터는 앱의 매니페스트 파일에 보안 구성(security configuration)이 있는 경우를 제외하고는 다른 앱에서 더 이상 이를 신뢰하지 않게 되었습니다.

Android 7의 또 다른 개선 사항은 기기를 완전히 루팅하지 않는 한 어떤 방법으로도 시스템 저장소에 인증서를 설치할 수 없게 되었다는 점입니다.

어쨌든 이 기능은 이전 버전과 최신 버전 모두에 남아 있었으며, 2019년에 마지막으로 게시된 앱까지 유지되었습니다.
실제 MITM 인증서는 2017년에 제거되었습니다.
법원 문서에서 이에 대한 그럴듯한 이유를 확인할 수 있습니다.

> *SSL bump에 사용되는 키는 어디에서 생성되며, 어떻게 남용으로부터 보호되나요?
> (예: 기기에서 생성되어, 해당 기기에만 사용되고, 기기를 벗어나지 않는지, 혹은 앱과 함께 다운로드되어 설치되는 공유 키가 있는지)*\
>\
> **인증서는 서버에서 생성되어 기기로 전송됩니다.**

![Page 3 - Case 3:20-cv-08570-JD Document 736](https://doubleagent.net/content/images/2024/04/image-15.png)

따라서 2019년 이전의 훨씬 더 오래된 버전으로 돌아가야 하며, 특히 2017년 9월 버전이 필요합니다.
이 버전에서는 "`old_ca.cer`"와 "`new_ca.cer`"라는 이름의 인증서가 `assets`에 포함되어 있습니다.
관련 코드는 `ResearchCertificateManager` 클래스에서 찾을 수 있습니다.

![ResearchCertificateManager](https://doubleagent.net/content/images/2024/04/image-7.png)

`.apk` 파일을 zip 파일로 압축 해제할 경우 이 파일들은 `assets` 폴더 아래에서 찾을 수 있습니다.
이는 JADX에서 확인되었습니다.

![assets folder](https://doubleagent.net/content/images/2024/04/image-9.png)

또한, 인증서가 설치되었는지 여부를 확인하는 루틴도 관찰되었습니다.

![check if the certificates have been installed or not](https://doubleagent.net/content/images/size/w1000/2024/04/image-8.png)

그렇다면 왜 두 개의 인증서가 있을까요? (`old`와 `new`)
여기 한 버전의 앱에서 추출된 두 개의 인증서가 있습니다.
첫 번째 인증서를 생성한 사람은 유효 기간을 1년으로만 설정했습니다.
만약 이것이 실수였다면, 만료 전에 이를 해결한 것으로 보입니다.

![old_ca.cer](https://doubleagent.net/content/images/2024/04/GJq8BYsbUAAiREe.png)

![new_ca.cer](https://doubleagent.net/content/images/2024/04/GJq8JjeaAAA59Ec.png)

*old_va.cer(위) vs new_ca.cer(아래)*

온라인에서 모든 버전의 `.apk` 파일을 찾을 수는 없었지만, 충분한 자료를 통해 다음과 같은 결론을 도출할 수 있었습니다.

- 첫 번째 인증서는 2016년 9월 8일부터 유효했으며, 이는 마크 주커버그가 스냅챗에 대한 추가 정보를 얻기 위해 요청을 보낸 시점(2016년 6월 9일자 이메일)보다 몇 달 뒤의 일입니다.
- 두 번째 인증서는 첫 번째 인증서와 함께 추가되었으며, 2017년 6월 8일부터 유효합니다. 이 인증서는 2027년 6월 8일까지 유효합니다.
- 최소 2027년 10월 19일부터는 인증서가 없으며, 두 번째 인증서는 앱에서 완전히 삭제되었습니다.
  앞서 언급했듯이 법원 문서에 따르면 인증서는 서버에서 얻어진 것으로 설명되어 있습니다.
  아카이브에서 확보한 앱들에서는 이와 관련된 기능을 아직 찾지 못했으며, 이에 대한 추가 작업이 필요합니다.

각각의 핑거프린트와 함께 인증서가 발견된 버전들:

![Versions with certificates found with their respective fingerprints](https://pbs.twimg.com/media/GJrEPLeaEAAhjQM?format=png&name=900x900)

법원 문서에 따르면 이후 유튜브(Youtube)와 아마존(Amazon)에 대한 추가적인 도청이 있었다고 합니다.
어떤 앱에서 어떻게 도청이 이루어졌는지는 더 자세히 조사해봐야 알 수 있을 것 같습니다:

![Page 2, case 3:20-cv-08570-JD Document 735](https://doubleagent.net/content/images/size/w1000/2024/04/image-12.png)

## 핵심 질문으로 돌아가서

완전히 인증서 고정(full certificate pinning)을 수행하는 앱은 이 기법을 방지했을 것입니다.
문제의 시기 동안 스냅챗은 일부분 인증서 고정(some certificate pinning)을 수행하고 있었지만, 모든 곳에서 적용된 것은 아니었습니다.

직접 확인하기 위해 이전 버전의 스냅챗 앱을 다시 가져와서 검사할 수 있습니다.
법원 문서에서 발견된 자료에 따르면, 해당 도메인은 `sc-analytics.appspot.com`이었습니다.

![Snapchat certificate pinning](https://pbs.twimg.com/media/GKBeIsTbgAAdHpH?format=png&name=small)

그리고 이전 버전의 스냅챗 앱을 디컴파일한 결과, 이 도메인으로의 트래픽은 인증서 고정을 사용하지 않았습니다.

![old Snapchat did not use certificate pinning](https://pbs.twimg.com/media/GKBnQNdb0AA2M8t?format=png&name=medium)

앞서 논의한 것처럼, 페이스북은 안드로이드의 보안 강화 및 인증서 고정의 광범위한 도입을 인지하고 있었으며, 이에 대한 언급이 포함되어 있습니다. (이전 `Page 3 - Case 3:20-cv-08570-JD Document 736` 참조)

> *인증서 고정이 최신 기기에서 기본적으로 적용되면서, 안드로이드에서 장기적으로 SSL bump가 적용될 수 있는지 일반적인 의문이 제기되고 있습니다.*

# 또 무엇이 있을까요?

제 눈에 띈 것은 [구독자 IMSI](https://en.wikipedia.org/wiki/International_mobile_subscriber_identity)를 얻으려는 요청이었습니다.
이는 매우 민감한 데이터입니다.

![subscriber IMSI](https://pbs.twimg.com/media/GJp7AoJaQAA5E-N?format=png&name=medium)

처음에는 이것이 어떻게 가능한지 궁금했는데, 당시에는 실제로 `READ_PHONE_STATE` 권한을 통해 가능했던 것으로 보입니다.

![Device Identifiers](https://pbs.twimg.com/media/GJqOvKmbwAAmL_p?format=png&name=medium)

물론 이는 앱의 매니페스트에 정의되어 있었습니다.

![app's manifest](https://doubleagent.net/content/images/size/w1000/2024/04/image-10.png)

*[Device identifiers | Android](https://source.android.com/docs/core/connect/device-identifiers)*

이걸 보면 아마도 조사할 것이 더 있을 겁니다.

# 마무리

이 모든 것이 몇 년 전에 일어난 "오래된 뉴스"이긴 하지만,
기술적인 관점에서 보면 애플리케이션 개발자들, 심지어 페이스북 같은 회사들이 모바일 폰의 권한 모델을 얼마나 악용할 수 있었는지를 보는 것은 흥미롭습니다.

그리고 CA 인증서 설치 절차를 트리거하는 루틴, 2017년 이후에 인증서가 어떻게 추가되었는지, Onavo 애플리케이션이 수집한 다른 데이터는 무엇인지 등 더 깊이 알아봐야 할 것들이 분명히 있습니다.
또한, 아이폰 버전의 애플리케이션도 찾을 수 있다면 좋을 텐데, 이를 찾을 수 있는 곳을 아는 사람이 있다면 도움이 될 것입니다.

그리고 CA 설치 절차를 트리거하는 루틴, 2017년 이후에 인증서가 추가되는 방법, Onavo 애플리케이션이 수집하는 다른 항목 등 더 알아봐야 할 것이 분명히 있습니다.
또한 사본을 어디서 찾을 수 있는지 아는 사람이 있다면 아이폰 버전의 애플리케이션을 찾는 것도 좋을 것입니다.

집단 소송이 흥미로운 방향으로 진행된다면, 이는 조사를 계속할 동기가 될 수 있을 것입니다.

추가 업데이트를 받고 싶으시다면, [원본 사이트에서 이메일 구독](https://doubleagent.net/onavo-facebook-ssl-mitm-technical-analysis/)을 등록하거나
[원저자의 X](https://x.com/haxrob)를 팔로우하세요.

[^1]: [셔먼법(Sherman Antitrust Act)](https://en.wikipedia.org/wiki/Sherman_Antitrust_Act)은 미국의 반독점법이다.
[^2]: [인증서 고정(Certificate Pinning)](https://learn.microsoft.com/ko-kr/azure/security/fundamentals/certificate-pinning)은 애플리케이션이 서버와 통신할 때 사용하는 SSL/TLS 인증서의 공인된 목록을 미리 지정해 두는 보안 기법입니다.
이를 통해 애플리케이션이 특정 인증서로만 서버에 연결하도록 제한합니다.
이 방식은 중간자 공격(MITM)을 방지하는 데 효과적입니다.
