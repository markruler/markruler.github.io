---
draft: true
date: 2024-09-08T21:59:00+09:00
lastmod: 2024-09-12T18:00:00+09:00
title: "Facebook은 경쟁사의 암호화된 모바일 앱 트래픽을 어떻게 가로챘을까?"
description: "@HaxRob"
featured_image: "/images/network/onavo-facebook-ssl-mitm-technical-analysis/fbdark-1.webp"
images: ["/images/network/onavo-facebook-ssl-mitm-technical-analysis/fbdark-1.webp"]
tags:
  - network
  - mitm
categories:
  - translate
---

> - HaxRob의 [How did Facebook intercept their competitor's encrypted mobile app traffic?](https://doubleagent.net/onavo-facebook-ssl-mitm-technical-analysis/)를 번역한 글입니다.
> - 원글의 작성일은 2024년 4월 14일입니다.
> - 저자의 허락을 받고 번역했습니다.
> - 각주는 역주입니다.

이 글은 Facebook 집단 소송에서 밝혀진 정보에 대한 기술적 조사입니다.
Facebook은 인사이트를 얻기 위해 Onavo Protect 앱이 실행중인 사용자의 디바이스에서 암호화된 트래픽을 도청했었습니다.

![How did Facebook intercept their competitor's encrypted mobile app traffic?](/images/network/onavo-facebook-ssl-mitm-technical-analysis/fbdark-1.webp)

*2024년 7월 28일 - 👋Hello [Hackernews](https://news.ycombinator.com/item?id=41090304)!*

현재 Meta를 상대로 한 집단 소송이 진행 중이며,
법원 문서에 따르면* Meta가 [도청법(Wiretap Act)](https://en.wikipedia.org/wiki/Electronic_Communications_Privacy_Act)을 위반했을 가능성이 있다고 명시되어 있습니다.
이 글은 [법원 문서](https://www.documentcloud.org/documents/24520332-merged-fb)와
보관된 Android 용 Onavo Protect 앱 패키지의 리버스 엔지니어링을 근거하여 작성되었습니다.

Facebook은 [MITM 공격](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)으로
간주될 수 있는 기법을 사용하여 사용자의 암호화된 HTTPS 트래픽을 가로챈 것으로 알려져 있습니다.
Facebook은 이 기법을 "ssl bump"라고 부릅니다.
이는 특정 Snapchat, YouTube, Amazon 도메인의 암호를 해독하는 데 사용된 것으로 추정되는
[Squid caching](https://www.squid-cache.org/)이라는 프록시 소프트웨어의
transparent proxy [기능 (ssl_bump)](https://www.squid-cache.org/Doc/config/ssl_bump/)의 이름을 따서 붙인 것입니다.
이 사건에 대한 자세한 배경은 최근 [TechCrunch](https://techcrunch.com/2024/03/26/facebook-secret-project-snooped-snapchat-user-traffic/) 기사를 참조하시기 바랍니다.

<p style="display:none;">
> [2024-07-28] - Note this is different to what TechCrunch [had revealed in 2019](https://techcrunch.com/2019/01/29/facebook-project-atlas/)
> in which Facebook were paying teenagers to gather data on usage habits.
> That resulted in the Onavo app being pulled from the app stores and [fines](https://www.accc.gov.au/media-release/20m-penalty-for-meta-companies-for-conduct-liable-to-mislead-consumers-about-use-of-their-data).
> With the new MITM information revealed:
> what is currently unclear is if all app users had their traffic "intercepted" or just a subset of users.
</p>

> [2024-07-28] - 이는 [2019년에 TechCrunch가 폭로한](https://techcrunch.com/2019/01/29/facebook-project-atlas/)
> Facebook이 청소년에게 돈을 주고 사용 습관에 대한 데이터를 수집한 것과는 다른 내용입니다.
> 이로 인해 Onavo 앱이 앱 스토어에서 삭제되고 [벌금이 부과되었습니다](https://www.accc.gov.au/media-release/20m-penalty-for-meta-companies-for-conduct-liable-to-mislead-consumers-about-use-of-their-data).
> 새로운 MITM 정보가 공개되면서 현재 모든 앱 사용자가 트래픽을 '가로챘는지' 아니면 일부 사용자만 트래픽을 가로챘는지 여부는 불분명해졌습니다.

<p style="display:none;">
> *A HN user [clarifies](https://news.ycombinator.com/item?id=41091505&ref=doubleagent.net):\
>\
> "This is not a wiretapping case.
> It's an antitrust case; the claims are all for violations of the Sherman Act.
> Plaintiffs' attorneys _incidentally_ found evidence during discovery that Facebook may have breached the Wiretap Act."
</p>

> *한 HN 사용자는 다음과 같이 [명확히 합니다](https://news.ycombinator.com/item?id=41091505&ref=doubleagent.net).\
> \
> "이 사건은 도청 사건이 아닙니다. 반독점 사건으로, 청구 내용은 모두 셔먼법[^1] 위반에 대한 것입니다.
> 원고의 변호사는 증거를 발견하는 과정에서 *우연히* Facebook이 도청법을 위반했을 수 있다는 증거를 발견했습니다."

[^1]: [셔먼법(Sherman Antitrust Act)](https://en.wikipedia.org/wiki/Sherman_Antitrust_Act)은 미국의 반독점법이다.

![Case 3:20-cv-08570-JD Document 735 Filed 03/23/24 Page 1](https://doubleagent.net/content/images/2024/07/image-1.png)

*\*Case 3:20-cv-08570-JD Document 735 Filed 03/23/24 Page 1*

> 제한적이고 국소적인 정보로 인해 이 글은 일부 사실이 부정확하거나 불완전할 수 있습니다.
> 따라서 이 글은 수정이 필요하거나 새로운 사실이 발견될 경우 업데이트될 수 있습니다.
> [저자의 블로그](https://doubleagent.net/onavo-facebook-ssl-mitm-technical-analysis/)를 구독하여 받은 편지함으로 새로운 콘텐츠를 받아보거나
> [저자의 X](https://twitter.com/haxrob)를 팔로우하세요.

- [요약](#요약)
- [동기](#동기)
- [분석](#분석)
- [CA 인증서와 함께](#ca-인증서와-함께)
- [다시 원래 질문으로 돌아가서](#다시-원래-질문으로-돌아가서)
- [또 있나요?](#또-있나요)
- [마무리](#마무리)

# 요약

- A review of an old Snapchat app shows that it's analytics domain did not employ certificate pinning,
  meaning that MITM / "ssl bumping" would have worked as described.
- In addition to the core functionality of gathering other app's usage statistics
  through abusing a permission granted by the user,
  there also appears to be other functionality to obtain questionable sensitive data,
  such as the subscriber [IMSI](https://en.wikipedia.org/wiki/International_mobile_subscriber_identity).
- [1,000만 개](https://www.androidrank.org/application/onavo_protect_from_facebook/com.onavo.spaceship)가 넘는
  안드로이드 설치 수를 기록한 [Onavo Protect 안드로이드 앱](https://apkpure.com/onavo-protect-from-facebook/com.onavo.spaceship)에는
  기기의 사용자 인증 저장소(user trust store)에 "Facebook Research"에서 발급한 CA(인증 기관) 인증서를 설치하도록 유도하는 코드가 포함되어 있었습니다.
  이 인증서는 Facebook이 TLS 트래픽을 해독하는 데 필요했습니다.
- 일부 구 버전의 앱에는 2016년에 배포된 앱에 embedded assets으로 Facebook Research CA 인증서가 포함되어 있습니다.
  그 중 하나의 인증서는 2027년까지 유효합니다.
  법원 문서의 데이터 발견(Data discovery) 내용에 따르면 인증서는 "서버에서 생성되어 기기로 전송"된다고 명시되어 있습니다.
- Protect 앱에 "ssl bump" 기능이 배포된 직후
  안드로이드의 새 버전이 출시되었으며, 이 버전에는 보안 제어 기능(security controls)이 개선되어
  새로운 운영 체제가 설치된 기기에서는 이 방법을 사용할 수 없게 되었습니다.
- 이전 Snapchat 앱을 검토한 결과, 분석 도메인에 인증서 고정이 사용되지 않았으며,
  이는 설명대로 MITM / "ssl bumping"이 작동했을 것임을 의미합니다.
- 구 버전의 Snapchat 앱을 검토한 결과, 해당 앱의 분석 도메인(analytics domain)이 인증서 고정을 사용하지 않았습니다.
  이는 MITM(중간자 공격) 또는 "SSL bumping"이 앞서 설명한 대로 작동했을 수 있음을 의미합니다.
- 사용자가 부여한 권한을 남용하여 다른 앱의 사용 통계를 수집하는 핵심 기능 외에도
  가입자 [IMSI](https://en.wikipedia.org/wiki/International_mobile_subscriber_identity)와 같이
  의심스러운 민감한 데이터를 획득하는 다른 기능도 있는 것으로 보입니다.

The setup most likely would have looked something the following diagram:

아마도 구성은 다음 그림과 비슷했을 것입니다:

![An interpretation of FB's setup based on court documents and app analysis](https://doubleagent.net/content/images/2024/04/fb1-3-1.png)

Here we have a trusted cert installed on the device,
all device traffic going over a VPN to Facebook controlled infrastructure,
traffic redirected into a Squid caching proxy setup as a transparent proxy with the 'ssl bump' feature configured.
We know from the documents that various domains belonging to Snapchat, Amazon and Youtube were of interest.
It's not known if any other user traffic was intercepted, or just proxied on.
This type of information we can't obtain from looking at the archived Onavo Protect apps,
rather for the time being, we have to rely on the content in the court documents made available to the public.

여기에는 디바이스에 신뢰할 수 있는 인증서가 설치되어 있고,
모든 디바이스 트래픽이 VPN을 통해 Facebook 제어 인프라로 이동하며,
트래픽이 'ssl bump' 기능이 구성된 투명 프록시로 설정된 Squid 캐싱 프록시로 리디렉션됩니다.
문서를 통해 Snapchat, Amazon, Youtube에 속한 다양한 도메인이 관심 대상이었다는 것을 알 수 있습니다.
다른 사용자 트래픽이 가로챈 것인지, 아니면 그냥 프록시된 것인지는 알 수 없습니다.
이러한 유형의 정보는 보관된 Onavo Protect 앱을 살펴봐서는 얻을 수 없으며 당분간은 일반에 공개된 법원 문서에 있는 내용에 의존해야 합니다.

Over time the success of their strategy to employ a transparent TLS proxy was diminishing due to improved security controls in Android.
Additionally certificate pinning adoption was said to be an issue.
As an alterative, Facebook were considering using the Accessibility API as an alternative.

시간이 지남에 따라 Android의 보안 제어 기능이 향상되면서 투명한 TLS 프록시를 사용하려는 전략의 성공이 줄어들고 있었습니다.
또한 인증서 고정 채택도 문제가 되고 있었습니다.
이에 대한 대안으로 Facebook은 접근성 API 사용을 고려하고 있었습니다.

![Page 3 - Case 3:20-cv-08570-JD Document 736](https://doubleagent.net/content/images/2024/04/image-14.png)

This is what Google has to say about using the accessibility features on their operating system:

운영 체제에서 접근성 기능을 사용하는 방법에 대한 Google의 답변입니다:

> *"only services that are designed to help people with disabilities access their device or otherwise overcome challenges stemming from their disabilities are eligible to declare that they are accessibility tools."*

> *"장애인이 기기에 액세스하거나 장애로 인한 문제를 극복하는 데 도움이 되도록 설계된 서비스만 접근성 도구라고 선언할 수 있습니다."*

It's somewhat telling of a company that would consider abusing features designed
to support people with disabilities for a competitive advantage.
Generally, Android accessibility functionality misuse is attributed to malicious applications
such as [banking malware](https://blog.pradeo.com/accessibility-services-mobile-analysis-malware).

장애인을 지원하기 위해 설계된 기능을 경쟁 우위를 위해 악용하려는 기업의 의도를 짐작할 수 있는 대목입니다.
일반적으로 Android 접근성 기능 오용은
[뱅킹 멀웨어](https://blog.pradeo.com/accessibility-services-mobile-analysis-malware)와 같은 악성 애플리케이션에 의해 발생합니다.

# 동기

Mark Zuckerberg states the need for "*reliable analytics*" on Snapchat:

마크 주커버그(Mark Zuckerberg)는 스냅챗에서 "*신뢰할 수 있는 분석*"의 필요성을 언급합니다:

![Mark Zuckerberg PX2255](https://doubleagent.net/content/images/2024/04/image-4.png)

The solution? "*Kits that can be installed on iOS and Android that intercept traffic for specific sub-domains*":

해결책은? "*특정 하위 도메인의 트래픽을 가로채는 iOS 및 Android에 설치할 수 있는 키트*"입니다:

![Danny Ferrante](https://doubleagent.net/content/images/size/w1000/2024/04/image-6.png)

My take on the above is that in addition to utilizing the Onavo Protect VPN app
to intercept traffic for specific domains,
there was an intention to rebrand the core technology and having it distributed in other applications.
Facebook had [acquired](https://techcrunch.com/2013/10/13/facebook-buys-mobile-analytics-company-onavo-and-finally-gets-its-office-in-israel/)
Onavo for approximately $120M USD in 2013 and needed to put this technology in good use.
That price point should give a clear indication on the value they placed on the ability
to gain competitor intelligence from people's phones and tablets.

제가 생각하기에는 특정 도메인의 트래픽을 가로채는 데 Onavo Protect VPN 앱을 활용하는 것 외에도
핵심 기술을 리브랜딩하여 다른 애플리케이션에 배포하려는 의도가 있었다고 생각합니다.
Facebook은 2013년에 약 1억 2천만 달러에 Onavo를 [인수했고](https://techcrunch.com/2013/10/13/facebook-buys-mobile-analytics-company-onavo-and-finally-gets-its-office-in-israel/)
이 기술을 잘 활용할 필요가 있었습니다.
이 가격대는 사람들의 휴대폰과 태블릿에서 경쟁사 정보를 얻을 수 있는 능력에 대한 가치를 명확하게 보여줄 수 있습니다.

[Prior research](https://medium.com/@chronic_9612/notes-on-analytics-and-tracking-in-onavo-protect-for-ios-904bdff346c0) on the iOS version
notes that the Onavo VPN app was collecting some usage telemetry from iPhones.
On Android we can see the app was pulling much more fine grained statistics
from their user's devices by utilizing permissions granted under the pretext of showing the user app data usage
(we will see how this looked in an embedded video below).
But that was not enough, Facebook wanted to take this one step further
and intercept encrypted traffic towards specific competitor's analytics domains in order to obtain data on the "**in-app actions**".

iOS 버전에 대한 [이전 연구](https://medium.com/@chronic_9612/notes-on-analytics-and-tracking-in-onavo-protect-for-ios-904bdff346c0)에 따르면
Onavo VPN 앱은 아이폰에서 일부 사용량 원격 분석을 수집하고 있었습니다.
Android에서는 앱이 사용자 앱 데이터 사용량을 표시한다는 구실로 부여된 권한을 활용하여
사용자 기기에서 훨씬 더 세분화된 통계를 가져오는 것을 확인할 수 있었습니다(아래 embedded 영상에서 그 모습을 확인할 수 있습니다).
하지만 그것만으로는 충분하지 않았고, Facebook은 한 걸음 더 나아가 '**인앱 행동 (in-app actions)**'에 대한 데이터를 얻기 위해
특정 경쟁사의 분석 도메인으로 향하는 암호화된 트래픽을 가로채고자 했습니다.

All they would need to do is to get the user to install a custom certificate
into the user's phone's trust store (and be on specific Android releases).

사용자가 사용자 휴대폰의 신뢰 저장소에 사용자 지정 인증서를 설치하도록 하기만 하면 됩니다(특정 Android 릴리스에 있어야 함).

> The wiretapping information is new and perhaps not to be confused with what occured prior:\
>\
> In 2023, two subsidiaries of Facebook was ordered to pay a total of $20M by the Australian Federal Court for "engaging in conduct liable to mislead in breach of the Australian Consumer Law", according to the [ACCC](https://www.accc.gov.au/media-release/20m-penalty-for-meta-companies-for-conduct-liable-to-mislead-consumers-about-use-of-their-data).\
>\
> Facebook had shutdown Onavo in 2019 after an [investigation](https://techcrunch.com/2019/01/29/facebook-project-atlas/) revealed they had been paying teenagers to use the app to track them.
> Also that year, Apple went as far as to [revoke Facebook's developer program certificates](https://web.archive.org/web/20220609072355/https://www.vox.com/2019/1/30/18203231/apple-banning-facebook-research-app), sending a clear message.\
>\
> Despite the apps being taken offline, we are able to find old archived versions which enabled the technical insights offered in this post.

> 도청 정보는 새로운 정보이므로 이전에 발생한 것과 혼동하지 마세요:\
>\
> [ACCC](https://www.accc.gov.au/media-release/20m-penalty-for-meta-companies-for-conduct-liable-to-mislead-consumers-about-use-of-their-data)에 따르면 2023년,
> Facebook의 두 자회사는 "호주 소비자법을 위반하여 오해를 불러일으킬 수 있는 행위를 했다"는 이유로 호주 연방법원으로부터 총 2천만 달러의 배상금을 지불하라는 명령을 받았습니다.\
> \
> Facebook은 2019년에 청소년에게 돈을 주고 앱을 사용해 청소년을 [추적한 사실](https://techcrunch.com/2019/01/29/facebook-project-atlas/)이 밝혀진 후 Onavo를 폐쇄했습니다.
> 또한 그 해에 애플은 [Facebook의 개발자 프로그램 인증서를 무효화(revoke)](https://web.archive.org/web/20220609072355/https://www.vox.com/2019/1/30/18203231/apple-banning-facebook-research-app)하여 분명한 메시지를 보냈습니다.\
> \
> 앱이 오프라인 상태임에도 불구하고 이 게시물에서 제공하는 기술적 인사이트를 가능하게 하는 오래된 아카이브 버전을 찾을 수 있었습니다.

# 분석

Websites and applications on end user devices trust remote websites or servers over HTTPS/TLS
due to public certificates that are stored in the device's trust store.
These "certificate authority" certs are the "trust anchor" that applications rely on to verify
they communicating with the intended party.
These certificates are generally distributed and stored within the operating system.
By adding your own self-signed certificate to the appropriate trust store,
it is often possible to intercept encrypted TLS traffic.
Corporations may also do this as a means of inspecting outbound traffic from employee's devices.
Security testers may also do this on their own devices.
There are legitimate reasons for doing this.
The question here is if what Facebook did was legitimate, meaning, was it legal or not.

최종 사용자 디바이스의 웹사이트와 애플리케이션은 디바이스의 신뢰 저장소에 저장된 공인 인증서로 인해 HTTPS/TLS를 통해 원격 웹사이트 또는 서버를 신뢰합니다.
이러한 "인증 기관(certificate authority)" 인증서는 애플리케이션이 의도한 상대방과 통신하는지 확인하기 위해 의존하는 "신뢰 앵커(trust anchor)"입니다.
이러한 인증서는 일반적으로 운영 체제 내에 배포 및 저장됩니다.
자체 서명된 인증서를 적절한 신뢰 저장소에 추가하면 암호화된 TLS 트래픽을 가로챌 수 있습니다.
기업에서는 직원 디바이스의 아웃바운드 트래픽을 검사하기 위한 수단으로 이 작업을 수행할 수도 있습니다.
보안 테스터가 자신의 디바이스에서 이 작업을 수행할 수도 있습니다.
이렇게 하는 데에는 정당한 이유가 있습니다.
여기서 문제는 Facebook이 한 행위가 합법적인지, 즉 합법적인지 아닌지의 여부입니다.

> There is some irony that the documentation for software that Facebook is said to employ to do the interception contains the following warning:

> Facebook이 감청을 위해 사용한다고 알려진 소프트웨어의 문서에 다음과 같은 경고가 포함되어 있다는 점은 아이러니합니다:

> *HTTPS was designed to give users an expectation of privacy and security. Decrypting HTTPS tunnels without user consent or knowledge may violate ethical norms and may be illegal in your jurisdiction.*

> *HTTPS는 사용자에게 개인정보 보호 및 보안에 대한 기대치를 제공하기 위해 설계되었습니다. 사용자 동의나 사용자 모르게 HTTPS 터널을 해독하는 행위는 윤리 규범을 위반할 수 있으며 관할 지역에서 불법일 수 있습니다.*

Unlike iOS on the iPhone, Google has made numerous changes to make it extremely difficult to install a CA cert that will be trusted by most applications on the phone. In Android 11, released in September 2020, Google had completely blocked the mechanism which the app used to prompt a user to install the cert and no application would trust any certificate in the user store by default.

iPhone의 iOS와 달리 Google은 휴대폰의 대부분의 애플리케이션에서 신뢰할 수 있는 CA 인증서를 설치하기가 매우 어렵도록 수많은 변경 사항을 적용했습니다.
2020년 9월에 출시된 Android 11에서는 앱이 사용자에게 인증서를 설치하라는 메시지를 표시하는 메커니즘을 완전히 차단하여
어떤 애플리케이션도 기본적으로 사용자 스토어에 있는 인증서를 신뢰하지 않습니다.

> People have asked "*what about cert pinning? wouldn't this have prevented successful MITM of the traffic?*"\
>\
> While that would be the case, as we will see later, at the time, the Snapchat app did not implement cert pinning for it's analytics domain. This would likely hold true for the other app domains. So it appears Facebook had leveraged off this technical limitation / oversight by it's competitors.

> 사람들은 "인증서 고정(Certificate Pinning)은 어떻게 하나요? 이렇게 하면 트래픽의 성공적인 MITM을 막을 수 없었을까요?"라고 질문합니다.\
> \
> 나중에 살펴보겠지만, 당시 Snapchat 앱은 분석 도메인에 대한 인증서 고정을 구현하지 않았습니다.
> 이는 다른 앱 도메인의 경우에도 마찬가지일 것입니다.
> 따라서 Facebook은 경쟁사의 이러한 기술적 제한/감독을 이용한 것으로 보입니다.

So today, technically speaking, is is simply is not possible to do what Facebook had done back in 2016 to 2019.
But it worked - so how did they do it? Fortunately, at least with Android and the Play store ecosystem,
we are able to often go back in time and sometimes dig up old Android app packages.

따라서 오늘날 기술적으로는 2016년부터 2019년까지 Facebook이 했던 일을 하는 것은 불가능합니다.
하지만 그들은 어떻게 해냈을까요?
다행히도 Android와 Play 스토어 생태계를 통해 우리는 종종 시간을 거슬러 올라가 오래된 Android 앱 패키지를 발굴할 수 있습니다.

The first thing is to install the Onavo app on a test handset to see how users would interact with the app.
Despite the VPN connectivity not working and the actual backend service being down,
we do get a glimpse on how the application coerces the user into accepting multiple permissions:

먼저 테스트 단말기에 Onavo 앱을 설치하여 사용자가 앱과 어떻게 상호 작용하는지 확인했습니다.
VPN 연결이 작동하지 않고 실제 백엔드 서비스가 다운되었지만,
애플리케이션이 사용자에게 여러 권한을 강제로 수락하도록 하는 방법을 엿볼 수 있었습니다:

<video src="https://doubleagent.net/content/media/2024/04/zszPzD8NSHAFb9W1.mp4" width="480" height="852" controls></video>

What we see here under pretext of providing the user 'protection', two particular permissions are of concern:

여기서 사용자 '보호'를 제공한다는 구실로 볼 때 두 가지 특정 권한이 우려됩니다:

- 다른 앱 위에 표시 (Display over other apps)
- 과거 및 삭제된 앱 사용 내역에 액세스 (Access past and deleted app usage)

> *"We need this permission to show you how much mobile data your apps use."*

> *"앱에서 사용하는 모바일 데이터의 양을 표시하려면 이 권한이 필요합니다."*

What they didn't explain is that this feature is not so much for the benefit of the user who installed the app, but actually Onavo/Facebook.
And this type of information is valuable, to the tune of $120M (what FB paid in the acquisition).

이 기능은 앱을 설치한 사용자의 이익을 위한 것이 아니라 실제로는 Onavo/Facebook을 위한 기능이라는 점을 설명하지 않았습니다.
그리고 이러한 유형의 정보는 1억 2천만 달러(FB가 인수에 지불한 금액)에 달할 정도로 가치가 있습니다.

![Onavo App Permissions](https://pbs.twimg.com/media/GJpCkIEbkAAsckm?format=jpg&name=small)

The Android manifest includes the `uses-permission` directive `android.permission.PACKAGE_USAGE_STATS`
which is what we are agreeing to in the screenshot above:

Android 매니페스트에는 위의 스크린샷에서 동의한 `uses-permission` 지시어의
`android.permission.PACKAGE_USAGE_STATS`가 포함되어 있습니다:

![PACKAGE_USAGE_STATS](https://pbs.twimg.com/media/GJptvfla8AA0rVZ?format=png&name=medium)

Continuing with the "application stats" feature (assumed to be the original core functionality), we can dump the schema of the local database on the handset to get an idea on exactly what it was collecting on the device itself:

"애플리케이션 통계(application stats)" 기능(원래 핵심 기능으로 가정)을 계속 진행하면
모바일 기기의 로컬 데이터베이스 스키마를 덤프하여 디바이스 자체에서 수집하는 정보를 정확히 파악할 수 있습니다:

![collecting on the device](https://pbs.twimg.com/media/GJpyTakbIAAeD_A?format=png&name=large)

Mostly it seems they could just obtain statistics on in app usage of other applications and of course the network traffic usage for the apps. It's still somewhat high level statistics and clearly not enough granularity for what Mark was after, implied by one of the emails in the court documents. Intercepting the actual encrypted traffic towards the analytics domains of various competitors on the other hand, would do the trick. And to do this, Facebook would have to get a CA certificate somehow on the device.

대부분 다른 애플리케이션의 인앱 사용량과 해당 앱의 네트워크 트래픽 사용량에 대한 통계만 얻을 수 있었던 것으로 보입니다.
이는 여전히 다소 높은 수준의 통계이며, 법원 문서에 있는 이메일 중 하나에서 암시하듯이 마크가 추구한 목표에 대한 세분성이 충분하지 않습니다.
반면에 다양한 경쟁사의 분석 도메인으로 향하는 실제 암호화된 트래픽을 가로채는 것이 효과적일 수 있습니다.
이를 위해 Facebook은 어떻게든 기기에서 CA 인증서를 발급받아야 합니다.

But we don't see any prompt to install any certificate.
This is because the VPN did not successfully connect to the remote service, which appears to be precondition.
Time or interest permitting, I may go back to figure out how to trigger the certificate installation prompt.

하지만 인증서를 설치하라는 메시지가 표시되지 않습니다.
이는 VPN이 원격 서비스에 성공적으로 연결되지 않았기 때문이며, 이는 전제 조건으로 보입니다.
시간이나 관심이 허락한다면 다시 돌아가서 인증서 설치 프롬프트를 트리거하는 방법을 알아볼 수 있습니다.

![Connections timing out, and a tcpdump shows that all traffic from the device is dropped after the VPN connection is initiated](https://doubleagent.net/content/images/size/w1000/2024/04/GJo--s8aQAAYwtL.png)

# CA 인증서와 함께

Decompiling the app, we do see the functionality is there.
In the following image, the method highlighted calls `KeyChain.createInstallIntent()` to install a certificate.
Here a popup would appear asking the user for permission, with the name "Facebook Research"

앱을 디컴파일하면 기능이 있는 것을 확인할 수 있습니다.
다음 이미지에서 강조 표시된 메서드는 `KeyChain.createInstallIntent()`를 호출하여 인증서를 설치합니다.
그러면 사용자에게 "Facebook Research"라는 이름으로 권한을 요청하는 팝업이 나타납니다.

![KeyChain.createInstallIntent](https://doubleagent.net/content/images/2024/04/GJpP7rmaAAAQDKI.png)

`KeyChain.createInstallIntent()` [stopped working](https://commonsware.com/R/pages/chap-security-004.html) in Android 7 (Nougat).
A user would have to manually install the certificate.
It would no longer be possible to have Facebook's CA cert installed directly in the app.

Android 7(Nougat)에서 `KeyChain.createInstallIntent()`가 [작동을 멈췄습니다](https://commonsware.com/R/pages/chap-security-004.html).
사용자가 인증서를 수동으로 설치해야 합니다.
더 이상 Facebook의 CA 인증서를 앱에 직접 설치하는 것은 불가능합니다.

Another notable change in Android 7 - According to the [Android documentation](https://developer.android.com/privacy-and-security/security-config) (emphasis mine):

Android 7의 또 다른 주목할 만한 변경 사항 - [Android 문서](https://developer.android.com/privacy-and-security/security-config) 인용 (강조는 필자):

> *By default, secure connections (using protocols like TLS and HTTPS) from all apps trust the pre-installed system CAs, and **apps targeting Android 6.0 (API level 23) and lower also trust the user-added CA store by default***

> *기본적으로 모든 앱의 보안 연결(TLS 및 HTTPS와 같은 프로토콜 사용)은 사전 설치된 시스템 CA를 신뢰하며, **Android 6.0(API 레벨 23) 이하를 대상으로 하는 앱은 기본적으로 사용자가 추가한 CA 저장소를 신뢰합니다**.*

In other words, it appears other apps would have trusted certs in the user store from Android Marshmallow (Android 6) and below, but from Android 7, released in August 22, 2016, they would no longer be trusted at all by other applications, unless due to a security configuration in the app's manifest file.

즉, Android Marshmallow(Android 6) 이하에서는 다른 앱이 사용자 스토어에서 인증서를 신뢰했지만
2016년 8월 22일에 출시된 Android 7부터는 앱의 매니페스트 파일에 보안 구성(security configuration)이 없는 한 다른 앱이 더 이상 인증서를 신뢰하지 않는 것으로 보입니다.

Another improvement to Android in version 7 was that it was made impossible to install certificates into the system store by any means except by fully rooting the device.

버전 7에서 Android의 또 다른 개선 사항은 기기를 완전히 루팅하지 않는 한 어떤 방법으로도 시스템 스토어에 인증서를 설치할 수 없게 되었다는 점입니다.

Regardless, the functionality remained in both the older version and newer, all the way to the last published app in 2019. The actual MITM certificate was removed in 2017. Detail in the court documents may offer plausible explanation:

그럼에도 불구하고 이 기능은 2019년에 마지막으로 게시된 앱까지 이전 버전과 최신 버전 모두에 남아 있었습니다.
실제 MITM 인증서는 2017년에 삭제되었습니다.
법원 문서에 자세히 설명되어 있으면 그럴듯한 설명이 될 수 있습니다:

> *Where is the key generated that's used for the SSL bump and how it protected from abuse? (e.g., is generated on the device, specific to that device, and never leaves the device, or is there a shared key that's downloaded with the app and installed)*\
>\
> ***The certificate is generated on the server and being sent to the device***

> *SSL bump에 사용되는 키는 어디에서 생성되며 남용으로부터 어떻게 보호되나요?
> (예를 들면, 기기에서 생성되어 해당 기기에서만 사용되며 기기를 벗어나지 않는지, 앱과 함께 다운로드되어 설치되는 공유 키가 있는지)*\
> \
> **인증서가 서버에서 생성되어 장치로 전송됩니다.**

![Page 3 - Case 3:20-cv-08570-JD Document 736](https://doubleagent.net/content/images/2024/04/image-15.png)

So we need to go back to much older releases before 2019, specifically a version from September 2017.
The certificates in this version are found as assets named "`old_ca.cer`" and "`new_ca.cer`".
The relevant code is found in the class `ResearchCertificateManager`.

따라서 2019년 이전의 훨씬 이전 릴리스, 특히 2017년 9월의 버전으로 돌아가야 합니다.
이 버전의 인증서는 "`old_ca.cer`" 및 "`new_ca.cer`"이라는 이름의 assets으로 찾습니다.
관련 코드는 `ResearchCertificateManager` 클래스에서 찾을 수 있습니다.

![ResearchCertificateManager](https://doubleagent.net/content/images/2024/04/image-7.png)

The can be found under the "assets" folder (if uncompressing the .apk as a zip file). Observed in JADX:

.apk를 zip 파일로 압축을 푼 경우 "assets" 폴더에서 찾을 수 있습니다. JADX에서 관찰됩니다:

![assets folder](https://doubleagent.net/content/images/2024/04/image-9.png)

Also observing the routine to check if the certificates have been installed or not:

또한 인증서가 설치되었는지 여부를 확인하는 루틴을 관찰합니다:

![check if the certificates have been installed or not](https://doubleagent.net/content/images/size/w1000/2024/04/image-8.png)

Now why would there be two certificates? (old and new)?
Here are the two certificates pulled from one version of the app.
Whoever had created the first certificate had only issued it to be valid for one year.
If this was an oversight, they did manage to figure it out before the expiry time.

왜 두 개의 인증서가 있을까요? (이전 버전과 새 버전)?
다음은 앱의 한 버전에서 가져온 두 개의 인증서입니다.
첫 번째 인증서를 만든 사람은 1년 동안만 유효하도록 발급했습니다.
만약 이것이 실수였다면 만료 시간 전에 알아낼 수 있었을 것입니다.

![old_ca.cer](https://doubleagent.net/content/images/2024/04/GJq8BYsbUAAiREe.png)

![new_ca.cer](https://doubleagent.net/content/images/2024/04/GJq8JjeaAAA59Ec.png)

*old_va.cer(위) vs new_ca.cer(아래)*

I have not been able to find all versions of the .apk online, but enough to draw the following conclusion:

온라인에서 모든 버전의 .apk를 찾을 수는 없었지만 다음과 같은 결론을 내릴 수 있을 정도였습니다:

- The first certificate was valid from Sep 8th 2016, some months before Mark Zuckerberg put the call out to gain further insight into Snapchat (email dated June 9th, 2016)
  - 첫 번째 인증서는 2016년 9월 8일부터 유효했는데, 이는 마크 저커버그가 스냅챗에 대한 추가 인사이트를 얻기 위해 전화를 걸기 몇 달 전이었습니다(2016년 6월 9일자 이메일).
- The second certificate was added alongside the first which was valid from Jun 8th, 2017. It will be valid until Jun 8 2027.
  - 두 번째 인증서는 2017년 6월 8일부터 유효한 첫 번째 인증서와 함께 추가되었습니다. 이 인증서는 2027년 6월 8일까지 유효합니다.
- At least from Oct 19th, 2027, there are no certs, the second cert was deleted from the app completely. As stated earlier, court documents explain certificates were obtained from the server. I have yet to locate the functionality relevant to this in the apps I have obtained from archives, and more work needs to be done here.
  - 적어도 2027년 10월 19일부터는 인증서가 없으며, 두 번째 인증서는 앱에서 완전히 삭제되었습니다. 앞서 언급했듯이 법원 문서에 따르면 인증서는 서버에서 획득한 것으로 설명되어 있습니다. 아카이브에서 확보한 앱에서 이와 관련된 기능을 아직 찾지 못했으며, 이에 대한 추가 작업이 필요합니다.

Versions with certificates found with their respective fingerprints:

각각의 핑거프린트가 있는 인증서 버전:

![Versions with certificates found with their respective fingerprints](https://pbs.twimg.com/media/GJrEPLeaEAAhjQM?format=png&name=900x900)

The court documents state that there was additional interception of YouTube and Amazon at later dates. Here we would have to dig further to find out in which apps and how this was done:

법원 문서에는 나중에 YouTube와 Amazon에 대한 추가 도청이 있었다고 명시되어 있습니다.
어떤 앱에서 어떻게 도청이 이루어졌는지는 더 자세히 조사해봐야 알 수 있을 것 같습니다:

![Page 2, case 3:20-cv-08570-JD Document 735](https://doubleagent.net/content/images/size/w1000/2024/04/image-12.png)

# 다시 원래 질문으로 돌아가서

Any app doing full certificate pinning would have prevented this technique from working. Around the time period in question, Snapchat was doing some certificate pinning. But not everywhere.

전체 인증서 고정을 수행하는 앱이라면 이 기술이 작동하지 않았을 것입니다.
문제의 기간 동안 Snapchat은 일부 인증서 고정을 하고 있었습니다.
하지만 모든 곳에서 그런 것은 아니었습니다.

We can go back and grab an old Snapchat app and check for ourselves. What was the domain? According to one the artefacts in the document discovery, it was `sc-analytics.appspot.com`:

돌아가서 이전 Snapchat 앱을 가져와서 직접 확인할 수 있습니다.
도메인은 무엇이었나요?
문서 검색에서 발견된 아티팩트 중 하나에 따르면 이 도메인은 `sc-analytics.appspot.com`이었습니다:

![Snapchat certificate pinning](https://pbs.twimg.com/media/GKBeIsTbgAAdHpH?format=png&name=small)

And behold, in a decompilation of and old Snapchat app, traffic to this domain did not use certificate pinning:

그리고 이전 Snapchat 앱의 디컴파일에서 이 도메인으로의 트래픽은 인증서 고정을 사용하지 않았습니다:

![old Snapchat did not use certificate pinning](https://pbs.twimg.com/media/GKBnQNdb0AA2M8t?format=png&name=medium)

As discussed earlier, Facebook were aware of the security enhancements in Android and the wider adoption of pinning, with the statement included (reference earlier):

앞서 설명한 바와 같이, Facebook은 Android의 보안 강화와 고정 기능의 광범위한 도입을 인지하고 있었으며, 이에 대한 성명을 발표했습니다(이전 참조):

> *There is a general question on SSL bump long term applicability on Android as SSL pinning by default is present on newer devices.*

> *최신 기기에는 기본적으로 SSL 고정이 적용되므로 Android에서 SSL bump가 장기적으로 적용 가능한지에 대한 일반적인 질문이 있습니다.*

# 또 있나요?

This one caught my eye, a request to obtain
the [subscriber IMSI](https://en.wikipedia.org/wiki/International_mobile_subscriber_identity).
A very sensitive bit of data indeed:

이 요청이 제 눈에 띄었는데,
바로 [구독자 IMSI](https://en.wikipedia.org/wiki/International_mobile_subscriber_identity)를 요청하는 것이었습니다.
실제로 매우 민감한 데이터입니다:

![subscriber IMSI](https://pbs.twimg.com/media/GJp7AoJaQAA5E-N?format=png&name=medium)

Initially I was wondering how this is even possible, and it seems at the time, it was actually possible with the permission `READ_PHONE_STATE`:

처음에는 이것이 어떻게 가능한지 궁금했는데, 당시에는 실제로 `READ_PHONE_STATE` 권한으로 가능했던 것 같습니다:

![Device Identifiers](https://pbs.twimg.com/media/GJqOvKmbwAAmL_p?format=png&name=medium)

Which of course was defined in the app's manifest:

물론 이는 앱의 매니페스트에 정의되어 있습니다:

![app's manifest](https://doubleagent.net/content/images/size/w1000/2024/04/image-10.png)

Given this discovery, there is probably more to explore.

이 발견을 고려할 때 앞으로 더 많은 것을 탐구할 수 있을 것입니다.

# 마무리

While this is all "old news" in the sense that happened years ago, it is interesting from a technical standpoint to see how far application developers, and even companies like Facebook will go to abuse permission models on mobile phones.

수년 전에 일어난 일이라는 점에서 이 모든 것이 "오래된 뉴스"이지만,
애플리케이션 개발자, 심지어 Facebook과 같은 회사가 휴대폰에서 권한 모델을 어디까지 남용할지 지켜보는 것은 기술적 관점에서 흥미롭습니다.

And there is certainly is more to dig into, such as the routine to trigger the CA install procedure, how certs were added after 2017 and what else the Onavo application was collecting. Also, it would also be nice to find iPhone version of the application if anyone knows where to find copies.

그리고 CA 설치 절차를 트리거하는 루틴, 2017년 이후에 인증서가 추가되는 방법, Onavo 애플리케이션이 수집하는 다른 항목 등 더 알아봐야 할 것이 분명히 있습니다.
또한 사본을 어디서 찾을 수 있는지 아는 사람이 있다면 iPhone 버전의 애플리케이션을 찾는 것도 좋을 것입니다.

If the class action lawsuit progresses in an interesting way, perhaps this could provide further motivation to continue the exploration.

집단 소송이 흥미로운 방식으로 진행된다면, 이는 탐사를 계속할 수 있는 동기를 제공할 수도 있습니다.

If you are interested in receiving further updates,
feel free to subscribe below with an email address, and/or follow me on [X](https://twitter.com/haxrob).

추가 업데이트를 받고 싶다면 [원본 사이트에 이메일 구독](https://doubleagent.net/onavo-facebook-ssl-mitm-technical-analysis/)하거나
[저자의 X](https://twitter.com/haxrob)를 팔로우하세요.
