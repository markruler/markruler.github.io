---
date: 2021-01-02T08:50:00+09:00
lastmod: 2021-01-02T08:50:00+09:00
title: "CS Visualized: CORS"
description: "Lydia Hallie"
# featured_image: "/images/web/lydia/cover-cors.jpg"
images: ["/images/web/lydia/cover-cors.jpg"]
socialshare: true
tags:
  - web
  - security
Categories:
  - translate
---

> - 리디아 할리(Lydia Hallie, [@lydiahallie](https://twitter.com/lydiahallie))가 쓴 [CS Visualized: CORS](https://dev.to/lydiahallie/cs-visualized-cors-5b8h)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

어쩌다 콘솔에서 "fetch 접근이 CORS 정책에 의해 차단되었습니다"라는
커다란 빨간색 오류를 보면 모든 개발자가 짜증을 느낍니다! 😬
임시방편이 몇 가지 있긴 하지만 오늘은 그 어떤 것도 사용하지 않겠습니다!
대신 CORS가 실제로 무엇을 하고 있는지 왜 우리에게 도움이 되는지
알아보도록 하겠습니다. 👏🏼

> ❗️ 이 글에서는 HTTP 기본에 대해 설명하지 않겠습니다.
> HTTP 요청과 응답에 대해 더 자세히 알고 싶으시다면 제가 얼마 전에
> 작성한 [짧은 글](https://www.lydiahallie.dev/blog/http11)이
> 있습니다. 🙂 제가 사용한 예시에서 HTTP/2 대신 HTTP/1.1을
> 사용하지만 CORS에 영향을 미치지는 않습니다.

---

우리는 종종 프런트엔드에서 다른 곳에 있는 데이터를 보여주고 싶습니다!
해당 데이터를 가져오기 위해 브라우저는 먼저 서버에 요청을 해야 하죠!
이 요청은 서버가 데이터를 클라이언트로 보내기 위해 필요한
모든 정보를 포함합니다. 🙂

예를 들어 웹사이트 `www.mywebsite.com`에서 `api.website.com` 서버에
있는 사용자 정보를 가져오려고 합니다!

![request-same](/images/web/lydia/request-same.gif)

Perfect! 😃 방금 서버로 HTTP 요청을 보냈습니다.
그런 다음 서버는 우리가 요청했던 JSON 데이터를 응답했습니다.

*동일한* 요청을 **다른 도메인**에 시도해보겠습니다.
`www.mywebsite.com` 대신
`www.anotherdomain.com`에서 요청하겠습니다.

![request-another](/images/web/lydia/request-another.gif)

잠깐, 뭐죠? 우리는 똑같은 요청을 보냈는데 이번에는 브라우저가 이상한 오류가 보여주죠?

우리는 방금 CORS가 동작하는 것을 보았습니다! 💪🏼
그럼 이 오류가 발생한 원인과 정확히 무엇을 뜻하는지 알아보겠습니다.

# ✋🏼 같은 출처 정책 (Same-Origin Policy)

웹은 **같은 출처 정책**이라는 것을 시행합니다. 기본적으로 우리는
요청을 하는 곳과 **같은 출처**에 있는 자원만 접근할 수 있습니다! 💪🏼
예를 들어 `https://mywebsite.com`에서 `https://mywebsite.com/image1.png`에
있는 이미지를 불러 오는 것은 괜찮습니다.

만약 자원이 다른 (하위)도메인 또는 다른 프로토콜, 다른 포트에 있는 경우
다른 출처(cross-origin)에 있다고 말합니다!

![origin](/images/web/lydia/origin.png)

좋아요, 그런데 왜 같은 출처 정책까지 있는 거죠?

만약 같은 출처 정책이 없었고 이모가 페이스북에서 보낸
수많은 바이러스 링크 중 하나를 실수로 클릭했다고 가정해 보세요.
이 링크가 여러분을 "유해 사이트"로 리다이렉션 시킵니다.
은행 사이트를 불러 오는 iframe이 내장된 웹사이트로요.
그리고 설정되어 있던 쿠키를 통해 성공적으로 로그인합니다! 😬

"유해 사이트" 개발자들은 본인 계좌로 돈을 보내기 위해
웹사이트가 이 iframe에 접근하고 은행 사이트 DOM 콘텐츠에
접근할 수 있게끔 만들었습니다!

> 역주: 위 공격은 CSRF (Cross-Site Request Forgery) 공격에 해당되며
> XSS (Cross-Site Scripting)도 같은 출처 정책과 관련된 공격입니다.

![wo-same-origin-policy](/images/web/lydia/wo-same-origin-policy.gif)

맞습니다... 이건 엄청난 보안 위험이에요! 우리는 그 누구도 접근하지 못하길 바랍니다. 😧

운 좋게도 여기서 같은 출처 정책이 우리를 도와줍니다!
이 정책은 **같은 출처** 자원만 접근할 수 있도록 합니다.

![with-policy](/images/web/lydia/with-policy.gif)

이 경우 `www.evilwebsite.com`은 다른 출처인 `www.bank.com` 자원에
접근하려고 했습니다! 같은 출처 정책은 이러한 일이 발생하지 않도록 접근을
차단하고 유해 사이트 개발자가 우리의 은행 데이터에 접근할 수 없도록 만듭니다. 🥳

좋아요, 그럼... 이것이 CORS와 무슨 관계가 있나요?

---

# 🔥 클라이언트 측 CORS

같은 출처 정책은 실제로 스크립트에만 적용되지만, 브라우저는 자바스크립트에서
요청하는 것까지 이 정책을 "확장"시킵니다. 기본적으로 우리는 **같은 출처**에서
가져온 자원만 접근할 수 있습니다!

![client-side-cors](/images/web/lydia/client-side-cors.gif)

흠, 하지만... 때로는 다른 출처 자원에 접근해야만 합니다. 🤔
프런트엔드가 데이터를 불러 오기 위해 백엔드 API를 호출해야 할 수도 있습니다.
그래서 브라우저는 다른 출처 요청을 안전하게 만들기 위해 **CORS**라는
메커니즘을 사용합니다! 🥳

CORS는 **다른 출처 자원 공유(Cross-Origin Resource Sharing)** 를 말합니다.
브라우저가 같은 출처가 아닌 자원에 접근할 수 없게 하지만, CORS를 사용하여
이러한 보안 제한을 약간 바꿔서 다른 출처 자원에 안전하게 접근할 수 있습니다. 🎉

사용자 에이전트(예: 브라우저)는 차단될 **다른 출처 요청을 허용**하기 위해
HTTP 응답의 특정 CORS 헤더 값에 따라 CORS 메커니즘을 사용할 수 있습니다! ✅

다른 출처 요청을 하면 클라이언트는 자동으로 HTTP 요청에
`Origin` 헤더를 추가합니다. `Origin` 헤더 값은 요청을 보낸 출처입니다!

![origin-header](/images/web/lydia/origin-header.gif)

브라우저가 다른 출처 자원에 접근할 수 있도록 클라이언트의 `Origin` 헤더는
해당 서버에게 다른 출처 요청 허용 여부를 명시한 응답 헤더를 요구하는 것입니다!

---

# 💻 서버 측 CORS

서버 개발자는 HTTP 응답에 헤더를 추가하여 다른 출처 요청이 허용되는지
확인시켜줄 수 있습니다. 이 헤더는 모두 `Access-Control-*`로 시작합니다. 🔥
이 CORS 응답 헤더의 값에 따라 브라우저는 일반적으로 같은 출처
정책에 의해 차단되는 특정 다른 출처 응답을 허용할 수 있습니다!

사용할 수 있는 [여러 CORS 헤더](https://fetch.spec.whatwg.org/#http-responses)가
있지만 브라우저가 다른 출처 자원 접근을 허용하기 위해 필요한 헤더는 하나입니다.
바로 `Access-Control-Allow-Origin`입니다! 🙂 이 헤더 값은 서버의
**자원에 접근할 수 있는 출처**를 지정합니다.

`https://mywebsite.com`에서 접근할 서버를 개발 중인 경우
`Access-Control-Allow-Origin` 헤더에 해당 도메인을 추가할 수 있습니다!

![access-control-allow-origin](/images/web/lydia/access-control-allow-origin.gif)

Awesome! 🎉 이제 서버가 클라이언트로 보내는 응답에 이 헤더가 추가됩니다.
그럼 `https://mywebsite.com`에서 요청을 보내도 `https://api.mywebsite.com`
**자원을 가져가는 걸 같은 출처 정책이 더 이상 막지 않습니다**!

![allowed-origins](/images/web/lydia/allowed-origins.gif)

브라우저 내부 CORS 메커니즘은 `Access-Control-Allow-Origin` 헤더 값이
요청할 때 보낸 `Origin` 값과 동일한지 확인합니다. 🤚🏼

이 경우 요청 출처는 `https://www.mywebsite.com`으로
응답 헤더 `Access-Control-Allow-Origin`에 실려 있습니다!

![response-header](/images/web/lydia/response-header.gif)

Perfect! 🎉 다른 출처 자원을 성공적으로 받을 수 있습니다!
그러면 `Access-Control-Allow-Origin` 헤더에 실려 있지 않은
출처에서 다른 출처 자원에 접근하려고 하면 어떻게 될까요? 🤔

![cors-error](/images/web/lydia/cors-error.gif)

맞아요. CORS는 때때로 악명 높은 에러를 던지죠!
하지만 우리는 이제 이것이 오히려 이치에 맞다는 것을 알게 되었습니다.

```text
'Access-Control-Allow-Origin' 헤더 값이
제공된 출처(Origin)와 다른 'https://www.mywebsite.com'입니다.
```

이 경우에 제공된 출처는 `https://www.anotherwebsite.com`입니다.
그러나 서버가 보낸 `Access-Control-Allow-Origin` 헤더에는 해당 출처가
없습니다! CORS가 요청을 차단했고 우리의 코드는 가져온 데이터에 접근할
수 없습니다. 😃

> 또한 CORS를 사용하면 허용되는 Origin 값으로 와일드카드 `*`를
> 추가할 수 있습니다. 이것은 모든 출처가 요청된 자원에
> 접근할 수 있다는 것이니 주의하세요!

---

`Access-Control-Allow-Origin`은 우리가 제공할 수 있는 수많은 CORS 헤더
중 하나입니다. 서버 개발자는 특정 요청을 허용하거나 차단하기 위해
CORS 정책을 수정할 수 있습니다! 💪🏼

또 하나 자주 사용되는 헤더는 `Access-Control-Allow-Methods`입니다!
CORS가 나열된 메서드들만 다른 출처 요청을 허용합니다.

![access-control-allow-methods](/images/web/lydia/access-control-allow-methods.gif)

이 경우 `GET`, `POST`, `PUT` 메서드 요청만 허용됩니다!
`PATCH` 또는 `DELETE`와 같은 다른 메서드들은 차단됩니다. ❌

> 다른 CORS 헤더는 무엇이 있으며 어떤 용도로 사용되는지 궁금하다면
> [이 목록을 확인해보세요](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#The_HTTP_response_headers).

CORS는 실제로 `PUT`, `PATCH`, `DELETE` 요청에 대해서는
다르게 처리합니다! 🙃 이렇게 "*단순하지 않은*" 요청은
**예비 요청** 이라는 것을 만듭니다!

---

# 🚀 예비 요청 (Preflighted Requests)

CORS에는 **단순 요청**과 **예비 요청**이라는 두 가지 요청이 있습니다.
요청이 단순 요청인지 예비 요청인지는 요청이 가진 일부 값에 따라
달라집니다(걱정하지 마세요. 이 내용을 외울 필요는 없습니다ㅋㅋㅋ).

단순 요청은 `GET` 또는 `POST` 메서드이고 사용자 정의 헤더가 없는 경우입니다!
예비 요청은 `PUT`, `PATCH` 또는 `DELETE` 메서드와 같은 다른 모든 요청입니다.

> 단순 요청이 되기 위해 어떤 요구 사항을 충족해야 하는지 궁금하다면 MDN에
> [유용한 목록](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Simple_requests)이 있습니다!

알겠어요, 근데 "예비 요청"은 뭐고 왜 이런 일이 일어나는 건가요?

---

실제 요청을 전송하기 전에 클라이언트는 예비 요청을 생성합니다!
예비 요청에는 `Access-Control-Request-*` 헤더에 실제로 보내려는
요청 정보가 포함되어 있습니다. 🔥

이 헤더는 브라우저가 수행하려는 실제 요청 정보를 서버에 제공합니다.
여기에는 요청 **메서드**, **추가 헤더** 등이 포함됩니다.

![preflighted-request](/images/web/lydia/preflighted-request.gif)

서버는 이 예비 요청을 수신하고 서버 CORS 헤더와 함께 텅 빈 HTTP 응답을 보냅니다!
브라우저는 CORS 헤더 외에 아무 데이터가 없는 예비 응답을 수신하고
해당 HTTP 요청이 허용되는지 여부를 확인합니다! ✅

![preflighted-response](/images/web/lydia/preflighted-response.gif)

이런 경우 브라우저가 실제 요청을 서버로 보내면
서버는 요청 받은 데이터를 응답합니다!

![actual-request](/images/web/lydia/actual-request.gif)

하지만 허용되지 않을 경우에는 CORS가 예비 요청을 차단하고 실제 요청은
절대 보내지지 않습니다. ✋🏼 예비 요청은 아직 CORS 정책이 적용되지 않은 서버의
자원에 접근하거나 수정할 수 없도록 하는 좋은 방법입니다! 서버가 잠재적으로
원하지 않는 다른 출처 요청으로부터 보호됩니다.😃

> 💡 서버 통신 횟수를 줄이기 위해 CORS 요청에 `Access-Control-Max-Age`
> 헤더를 추가하여 예비 요청에 대한 응답을 캐시할 수 있습니다!
> 그럼 브라우저는 새로운 예비 요청을 보내는 대신 캐시된 응답을
> 사용할 수 있습니다!

---

# 🍪 자격 증명(Credentials)

쿠키, 인가 헤더, TLS 인증서는 기본적으로 같은 출처 요청에서만 설정됩니다!
그러나 이러한 자격 증명을 다른 출처 요청에 사용할 수도 있습니다.
서버가 사용자를 식별하기 위해 사용하는 쿠키를 요청에 포함시킬 수도 있습니다!

기본적으로 CORS에 자격 증명이 포함되어 있지 않지만
CORS 헤더 `Access-Control-Allow-Credentials`를 추가할 수 있습니다! 🎉

다른 출처 요청에 쿠키 및 기타 인가 헤더를 포함시키려면
요청에 `withCredentials` 필드를 `true`로 설정하고
응답에 `Access-Control-Allow-Credentials` 헤더를 추가해야 합니다.

![access-control-allow-credentials](/images/web/lydia/access-control-allow-credentials.gif)

준비 끝! 이제 우리는 다른 출처 요청에 자격 증명을 포함시킬 수 있습니다. 🥳

---

제가 생각하기엔 우리 모두 CORS 오류가 가끔 짜증나지만
브라우저에서 다른 출처 요청을 안전하게 해준다는 것은 놀라울 거에요.
(좀 더 많은 사랑을 받아야 합니다 ㅋㅋㅋ) ✨

제가 이 블로그 포스트에서 다룰 수 있었던 것보다 더 많은 자료들이 있습니다!
더 궁금하다면 운 좋게도
[CORS in Action](https://livebook.manning.com/book/cors-in-action/part-1/)이나
[W3 규격](https://www.w3.org/wiki/CORS_Enabled)과 같은 좋은 자료들이 있습니다. 💪🏼

그리고 언제나 그랬듯이 저(Lydia Hallie)와 소통해요! 😊

|✨|👩🏽‍💻|💻|💡|📷|💌|
|---|---|---|---|---|---|---|
|[Twitter](https://www.twitter.com/lydiahallie)|[Instagram](https://www.instagram.com/theavocoder)|[GitHub](https://www.github.com/lydiahallie)|[LinkedIn](https://www.linkedin.com/in/lydia-hallie)|[YouTube](https://www.youtube.com/channel/UC4EWKIKdKiDtAscQ9BIXwUw)|[Email](mailto:lydiahallie.dev@gmail.com)|
