---
draft: true
socialshare: true
date: 2025-04-17T18:08:00+09:00
lastmod: 2025-04-17T18:08:00+09:00
title: "웹과 멀티미디어: 오디오"
description: "audio"
# featured_image: ["/images/master/markruler-wave.webp"]
images: ["/images/master/markruler-wave.webp"]
tags:
  - web
  - multimedia
  - audio
categories:
  - wiki
---

- [개요](#개요)
- [오디오 신호 처리](#오디오-신호-처리)
- [주요 오디오 코덱과 포맷](#주요-오디오-코덱과-포맷)
- [오디오 재생: HTML5 audio, MSE API, Web Audio API](#오디오-재생-html5-audio-mse-api-web-audio-api)
- [마이크 입력과 녹음: MediaDevices 및 MediaRecorder](#마이크-입력과-녹음-mediadevices-및-mediarecorder)
  - [MediaDevices.getUserMedia()로 오디오 입력 받기](#mediadevicesgetusermedia로-오디오-입력-받기)
  - [Web Audio API로 입력 스트림 처리하기](#web-audio-api로-입력-스트림-처리하기)
  - [MediaRecorder를 사용한 오디오 녹음](#mediarecorder를-사용한-오디오-녹음)
  - [Web Audio와 MediaRecorder의 조합](#web-audio와-mediarecorder의-조합)
- [브라우저의 오디오 재생 정책](#브라우저의-오디오-재생-정책)
- [오디오 성능](#오디오-성능)
- [결론](#결론)
- [더 읽을 거리](#더-읽을-거리)

# 개요

**물리적으로** 매질을 통해 전달된 모든 음파를 **사운드(sound)** 라고 합니다.
예를 들면 음성(voice)과 음악(music)을 포함한 사람의 귀로 들을 수 있는 모든 가청 영역의 소리를 말합니다.
한편 가청 영역 밖에 해당하는 초저주파나 초고주파(초음파)까지 포함하며 전자 신호로 처리할 수 있는 모든 소리를
**기술적으로** **오디오(audio)** 라고 합니다.

이 글에서는 오디오의 **입력(녹음)부터 처리, 출력(재생)까지**의 전체 흐름을 다룹니다.
주요 오디오 포맷의 특성과 브라우저 호환성, Web Audio API를 통한 실시간 처리와 **시각화(Visualization)**,
MediaRecorder를 통한 **녹음(Recording)**, 그리고 **브라우저 정책**까지 다뤄보겠습니다.

# 오디오 신호 처리

마이크를 통해 음원(audio source)으로부터 수집한 **아날로그 신호**는
**파동(wave)** 형태로 존재합니다.
파동의 **진폭(amplitude)이 클수록** 그 순간 **소리의 크기는 커집니다**.
**파장(wavelength)이 짧을수록**(파동의 간격이 좁을수록) 생성되는 소리의 **주파수(음높이)는 높아집니다**.

![오디오 파형](/images/multimedia/audio-in-web/audio-waveform.svg)

[이미지 출처: MDN](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Audio_concepts)

하지만 컴퓨터는 디지털입니다.
컴퓨터가 처리할 수 있는 방식으로 표현하려면 소리를 디지털 형태로 변환해야 합니다.
이것을 수행하는 것이 **아날로그-디지털 변환기(analog to digital converter)** 입니다[^1].
줄여서 ADC 혹은 A/D 변환기라고도 합니다.

대표적인 ADC 방식으로 [펄스 부호 변조(PCM, Pulse Code Modulation)](https://en.wikipedia.org/wiki/Pulse-code_modulation)가 있습니다.
PCM은 먼저 아날로그 신호를 디지털화하기 위해 일정한 간격으로 **표본화**(**Sampling**)합니다.
이것을 **펄스 진폭 변조**(**PAM, Pulse Amplitude Modulation**)라고 합니다.
이렇게 표현된 각각의 진폭을 **샘플**(**sample**)이라고 부릅니다.
1초당 샘플의 갯수를 헤르츠(Hertz) 단위로 표현하며,
이를 **샘플 레이트**(**sample rate**)라고 합니다.
예를 들어, 44,100 Hz(44.1 kHz)는 1초에 44,100개(1개에 1/44.1 ms)의 샘플을 수집한 것입니다.

![오디오 파형 샘플링](/images/multimedia/audio-in-web/audio-waveform-samples1.svg)

[이미지 출처: MDN](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Audio_concepts)

ADC가 아날로그 신호를 전압으로 변환하면
이때 각 샘플의 진폭을 [양자화(Quantization)](https://en.wikipedia.org/wiki/Quantization_(signal_processing))하여
이산적인 수치로 표현합니다.
여기서 양자화란 진폭을 일정한 간격으로 나누어 그 구간에 해당하는 정수값으로 반올림하여 표현하는 것입니다.
샘플별 양자화 값의 범위는 **양자화 레벨(quantization level)** 이라고 하며
비트(bit)로 표현됩니다.
예를 들어, 16비트 ADC는 65,536개의 구간으로 나누어 진폭을 표현합니다.
비트 수가 적을수록 구간이 넓어져 정밀도가 떨어지고
양자화 노이즈(quantization noise)가 발생합니다.

**압축되지 않은(raw) 오디오 데이터**는 용량과 대역폭을 크게 차지하기 때문에,
현실적으로 **코덱**을 통해 데이터량을 압축해서 전송합니다.
예를 들어, CD 품질의 오디오는 44.1 kHz 샘플링, 16비트 PCM으로 인코딩되며,
1초에 약 172.3 KiB의 대역폭을 차지합니다.

```plaintext
2(Stereo) * 2 Bytes(16 bit) * 44100(sample rate) = 176,400 Bytes
```

3분(180초)의 음원을 다운로드한다면 약 30.3 MiB의 용량이 필요합니다.

[코덱(codec)](https://en.wikipedia.org/wiki/Codec)은
coder/decoder의 합성어로 데이터 스트림이나 신호를 인코딩하거나 디코딩하는 요소입니다.
**포맷**은 그 데이터를 담는 **컨테이너**라 할 수 있습니다.
예를 들어 MP3라는 용어는 **MPEG-1 Audio Layer III**라는 압축 코덱을 가리키면서,
동시에 `.mp3` 확장자의 파일 포맷(컨테이너)을 지칭하기도 합니다.
코덱은 PCM과 같은 원시 오디오 데이터를 입력받아
사람이 듣기에 품질 저하가 최소화되도록 데이터를 줄이고(손실 압축의 경우),
반대로 압축된 데이터를 해석해 다시 PCM 등의 원시 형태로 복원합니다.

코덱에는 **무손실(lossless)** 압축과 **손실**(**lossy**) 압축이 있으며,
손실 압축은 **심리음향**(**psychoacoustics**)을 활용해 데이터량을 크게 줄입니다.
예를 들어, 사람의 귀로 들을 수 있는 **가청 주파수**(**audio frequency**) 범위만 남긴다거나
큰 소리 속에 섞인 작은 소리를 생략하는 등 지각하기 힘든 요소를 제거하는 **지각 부호화(perceptual coding)** 등의
기법을 활용할 수 있습니다.
이렇게 하면 파일 크기를 극적으로 줄일 수 있지만,
압축률을 높일수록 원음과 차이가 생기는 **손실(loss)** 이 발생합니다.

**압축된 오디오 비트스트림(bitstream, binary sequence)은 보통 컨테이너(container)에 저장되어 전송됩니다**.
컨테이너는 말 그대로 데이터를 담는 그릇으로, 오디오의 메타데이터(ex: 샘플레이트, 채널 수)와 비트스트림을 일정한 포맷으로 정리합니다.
흔히 **파일 확장자**로 컨테이너를 구분할 수 있습니다.
예를 들어 **WAV**는 주로 PCM 데이터를 담는 컨테이너이고,
**MP4(M4A)** 는 AAC와 같은 MPEG-4 계열 코덱을 담는 컨테이너입니다.
**Ogg**는 Vorbis나 Opus같은 오디오 코덱을 담을 수 있는 오픈 컨테이너이고,
**WebM**은 웹용 미디어 컨테이너로 똑같이 Vorbis나 Opus를 담습니다.
이러한 이유로 웹에서는 동일한 음원을 여러 포맷으로 제공하여
[브라우저 호환성](https://caniuse.com/?search=audio%20format)을 확보하기도 합니다.

# 주요 오디오 코덱과 포맷

웹에서 주로 쓰이는 몇 가지 코덱으로 범위를 좁혀볼 수 있습니다[^2].
각 코덱마다 압축 효율, 음질, 지연(latency), 라이센스 조건 등이 다르며 브라우저 지원 여부도 상이합니다.

- **MP3 (MPEG-1 Audio Layer III)** 는 가장 널리 알려진 손실 압축 오디오 코덱으로,
  음악 스트리밍과 디지털 음원 시장을 개척한 장본인입니다.
  MP3는 비교적 오래된 기술이지만 여전히 **모든 최신 브라우저에서 재생 지원**됩니다.
  `.mp3` 파일은 내부적으로 MPEG 형식 컨테이너를 사용하지만 영상 트랙 없이 오디오 트랙만 들어있을 경우 관례적으로 "MP3 파일"로 불립니다.
  MP3는 압축 효율이 최신 코덱보다 떨어지지만,
  **특허 만료**(미국 기준 2017년 만료)로 인한 자유로운 사용과 폭넓은 호환성 덕분에 웹에서 기본 지원 포맷으로 자리잡았습니다.
  일반적으로 **128~320 kbps** 범위의 비트레이트로 스테레오 음악을 인코딩하며,
  **192 kbps 이상**에서는 원본 CD음질에 근접한 품질을 기대할 수 있습니다.
- **AAC (Advanced Audio Coding)** 는 MP3 이후 MPEG 표준으로 채택된 손실 압축 코덱으로, MP3 대비 낮은 비트레이트에서도 양호한 음질을 제공합니다.
  AAC는 MPEG-4 Part 3에 정의되어 있으며 주로 **MP4(M4A)** 컨테이너에 담겨 `.mp4` 혹은 `.m4a` 확장자로 사용됩니다.
  웹 브라우저에서는 **MP4 컨테이너의 AAC**를 거의 모두 지원합니다 (모든 주요 브라우저에서 지원되는 매우 호환성 좋은 조합).
  특히 H.264/MP4 비디오와 함께 쓰이기도 하고, iTunes나 유튜브 등에서도 채택되어 있습니다.
  다만 AAC는 특허 코덱으로서 기술이 **비공개 및 라이선스 필요**하다는 점이 있지만,
  브라우저나 OS 차원에서 라이선스가 처리되어 일반 웹개발자가 신경쓸 부분은 아닌 경우가 많습니다.
  **256 kbps AAC**는 투명도(원음과의 차이를 느끼기 어려운 정도)가 높아 음원 다운로드에 종종 권장되며,
  **애플 기기** 및 **Safari** 브라우저 환경에서 특히 기본적인 포맷으로 취급됩니다.
- **Opus** 는 비교적 최신(2012년 표준화) 코덱으로, **Xiph.Org**와 **Mozilla** 등이 개발한 **오픈 소스** **손실 압축** 코덱입니다.
  Opus는 **웹 실시간 통신(WebRTC)** 표준 코덱으로 지정될 정도로 **낮은 지연(low latency)** 특성과 효율적인 압축을 모두 갖추고 있어,
  **음성 통화**부터 **음악 스트리밍**까지 폭넓게 활용됩니다.
  Opus는 **5~66.5ms 정도의 매우 낮은 지연시간 범위**를 가지며,
  다른 일반 음악 코덱들이 대개 100ms 이상의 지연을 보이는 것과 대비됩니다.
  음질 면에서도 Opus는 동일 비트레이트에서 MP3나 Vorbis보다 우수한 품질을 내며,
  합리적인 비트레이트(예: 스테레오 음악 128 kbps 정도)에서 투명도에 도달한다고 평가됩니다.
  Opus는 **완전 오픈소스/무특허** 코덱이라 라이선스 제약도 없습니다.
  단, **브라우저 지원**은 과거에 약간 제약이 있었습니다.
  Chrome, Firefox, Opera 등은 오래전부터 Opus를 지원했지만, Safari는 한동안 Opus를 직접 지원하지 않아 왔습니다.
  (Safari 11~14에서는 Opus 코덱을 **CAF 컨테이너**에 담은 경우에만 제한적으로 지원하는 등 제약이 있었고, 2020년대 중반에 들어 Safari도 WebM/Opus 지원을 도입하는 추세입니다.)
  Opus는 주로 **Ogg** 또는 **WebM(Matroska)** 컨테이너에 담겨 `.opus` (Ogg Opus) 또는 `.webm` (WebM Opus) 확장자로 사용되며,
  MP4 컨테이너에도 넣을 수 있지만 호환성은 케이스마다 다를 수 있습니다.
  최신 웹 환경에서는 Opus 지원이 점차 **보편화**되고 있으므로, **낮은 지연이 중요한 애플리케이션(예: 라이브 오디오 스트리밍, 실시간 통신)**에서 최우선으로 고려할 만합니다.
- **Vorbis** 는 Xiph.Org에서 개발한 이전 세대 **오픈소스 손실 압축** 코덱입니다.
  Ogg 컨테이너의 오디오 트랙으로 많이 사용되었고, MP3의 대안으로 한때 각광받았습니다.
  Vorbis는 MP3보다 같은 비트레이트에서 음질이 우수하며,
  **가변 비트레이트(VBR)** 인코딩을 선도적으로 채택했습니다.
  다만 Opus가 등장하면서 압축 효율과 지연 면에서 Vorbis를 대체하였고, 현재는 **과도기적 코덱**으로 평가됩니다.
  **브라우저 호환성** 측면에서 Vorbis 자체는 Chrome, Firefox 등에서 지원되지만 **Safari는 Ogg 컨테이너를 지원하지 않아** Vorbis 재생이 기본적으로 불가능했습니다.
  (Safari에서 Vorbis를 재생하려면 별도 플러그인이나 변환이 필요했습니다.)
  결과적으로 **최대 호환성**을 원한다면 Vorbis보다는 AAC나 MP3를 함께 제공하는 편이 좋습니다.
  완전 자유 라이선스이므로 특허 비용 없이 사용할 수 있다는 장점이 있습니다.
- **WAV(PCM)** 는 **비압축 PCM** 오디오 데이터(또는 일부 무손실 압축)를 담는 컨테이너 포맷입니다.
  용량이 크지만 구조가 단순하여 거의 모든 환경에서 **기본 지원**됩니다.
  웹 브라우저도 WAV/PCM 재생을 지원하며, 특히 **짧은 효과음이나 알림음** 등에서는 별도 압축 없이 WAV를 사용할 때도 있습니다.
  WAV의 단점은 앞서 언급한 대로 파일 크기가 크다는 것이므로, 네트워크 전송에는 비효율적입니다.
  만약 WAV를 사용하더라도 압축이 필요 없는 특수한 경우나, 파일 크기가 매우 작을 때로 한정하는 것이 좋습니다.
- **FLAC(Free Lossless Audio Codec)** 은 이름 그대로 **무손실 압축** 코덱입니다.
  음악을 완전히 원음 품질로 저장하면서도 WAV에 비해 용량을 40~50% 가량 줄일 수 있다는 장점이 있습니다.
  FLAC도 오픈 소스/무특허이며 `.flac` 자체의 컨테이너를 사용하거나, Ogg 컨테이너에 담아 `.ogg`로 쓸 수도 있습니다.
  브라우저에서는 Chrome과 Firefox 등이 FLAC 재생을 지원하며, 주로 **데스크톱** 환경에서 동작합니다 (모바일 브라우저 지원은 제한적일 수 있음).
  FLAC는 웹 스트리밍보다는 **고음질 음원 다운로드** 제공 시 옵션으로 쓰이며, 대부분의 경우 손실 압축으로도 충분한 웹 오디오와는 다소 분야가 다릅니다.

이 밖에도 웹에서는 **AMR(Adaptive Multi-Rate), G.711** 등의 **음성 코덱**이 WebRTC나 SIP 통신에 사용되고,
애플 기기 생태계에서는 무손실 압축 코덱으로 **ALAC(Apple Lossless)** 이 쓰이기도 합니다.
그러나 일반적인 웹 콘텐츠 오디오로는 앞서 언급한 코덱들이 주류를 이룹니다.
**요약하면, 웹에서 최대 범용성을 원한다면 AAC(MP4), MP3 두 가지를 우선 준비**하고,
가능하다면 Opus(Ogg 혹은 WebM) 버전을 추가로 제공해 현대 브라우저에서 **최적 품질/용량**을 활용하는 전략이 좋습니다.
`<audio>` 태그를 사용할 경우 `<source>` 요소를 통해 여러 포맷을 제공하면 브라우저가 지원되는 것을 골라 재생합니다.

```html
<audio controls>
  <source src="audio.ogg" type="audio/ogg; codecs=vorbis" />
  <source src="audio.mp3" type="audio/mpeg" />
  해당 브라우저에서는 오디오 재생을 지원하지 않습니다.
</audio>
```

위와 같이 작성하면 브라우저는 지원 가능한 코덱/포맷 조합을 가진 첫 번째 소스를 선택해 재생합니다[^3].
예를 들어 Safari는 Ogg/Vorbis를 지원하지 않으므로 무시하고 MP3 소스를 재생하며,
Firefox는 특허문제로 과거 MP3 지원이 불완전했으나 현재는 MP3도 지원하여 둘 다 재생 가능합니다.
이러한 다중 소스 제공을 통해 호환성을 극대화할 수 있습니다.
(현 시점에서는 대부분 MP3와 AAC로 충분하지만, **Opus**는 향후 점차 중요해질 것입니다.)

# 오디오 재생: HTML5 audio, MSE API, Web Audio API

웹에서 오디오를 재생하는 방법은 크게
**다운로드 후 재생**과 **스트리밍 재생** 두 가지로 나눌 수 있습니다.
또한 **디코딩**은 브라우저 내부에서 자동으로 이루어지지만,
개발자가 **Web Audio API** 등을 통해 수동으로 디코딩하여 사용하는 방식도 있습니다.

**프로그레시브 다운로드(Progressive download)** 는
가장 기본적인 오디오 전송 방법으로, 단순히 HTTP로 오디오 파일을 내려받으면서 바로 재생하는 것입니다.
`<audio>` 태그에 MP3 등의 URL을 지정하면 브라우저가 파일을 점진적으로 다운로드하고 **버퍼를 채우면서 곧바로 재생**합니다.
사용자는 전체 파일이 다운로드되기 전에 중간부터 듣기 시작할 수 있고, 탐색(seek)하면 해당 위치의 데이터를 요청합니다.
이 방식은 구현이 간단하지만, 네트워크 상태에 따라 재생 도중 버퍼가 소진되면 **일시 정지/버퍼링**이 발생할 수 있습니다.
`<audio>` 요소에서는 [readyState](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/readyState)나
[progress](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/progress_event)
이벤트 등을 통해 버퍼링 상태를 파악할 수 있고,
[canplay](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/canplay_event)/[canplaythrough](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/canplaythrough_event)
이벤트로 얼마나 로드되었는지 알 수 있습니다.
일반적인 짧은 음원이나 배경음악 등은 이 방식으로 충분합니다.

- **다중 포맷 소스**: 앞서 언급한 것처럼 `<source>` 태그를 이용해 서로 다른 코덱/포맷의 파일을 제공하면 브라우저가 지원 가능한 것을 선택합니다.
  이를 통해 호환성을 높일 수 있습니다.
  또한 `.canPlayType()` 메서드로 특정 MIME 유형 지원 여부를 사전 점검할 수도 있습니다 (ex: `audio.canPlayType('audio/ogg; codecs=opus')`).
- **미디어 이벤트**: `<audio>`/`<video>` 요소는 재생 상태를 알려주는 많은 이벤트를 지원합니다.
  예를 들어 `loadeddata` (메타데이터 및 일부 데이터 로드 완료), `timeupdate` (재생 시간이 변경될 때 주기적으로 발생), `ended` (재생 끝) 등을 활용해 UI를 업데이트하거나 다음 행동을 취할 수 있습니다.
  또한 버퍼링 관련 `waiting`/`playing` 이벤트나 `progress` 이벤트로 네트워크 상태에 따른 UX 대응도 가능합니다.
- **기본 컨트롤 vs 커스텀 UI**: `controls` 속성을 사용하면 브라우저 기본 컨트롤(UI)이 보이지만, 이를 숨기고 커스텀 플레이어를 만들 수도 있습니다.
  JavaScript로 play/pause를 제어하고, `<input type="range">`로 진행바를 구현하며, 볼륨 조절, 음소거 등을 `<audio>` 요소의 속성(`volume`, `muted`)으로 제어할 수 있습니다.
  MDN의 예제에서는 `<audio>` 요소를 숨기고 JavaScript로 사용자 정의 UI와 동기화하는 방법을 소개하고 있습니다.
- **제한 사항**: `<audio>` 요소는 **단일 트랙** 재생에는 간편하지만, 여러 소리를 믹싱하거나 실시간 신호 처리, 분석 등의 고급 기능에는 한계가 있습니다.
  또한 브라우저 **오디오 정책**에 따라 `autoplay`가 제한되기도 합니다 (뒤에서 설명).
  이러한 한계를 넘어서기 위해 고안된 것이 **Web Audio API**입니다.

```html
<audio id="player" src="music.mp3" controls autoplay></audio>
```

라이브 인터넷 라디오, 장시간 음악 스트리밍 서비스와 같이
**실시간성 또는 장시간 재생이 필요한 오디오**의 경우
**스트리밍 프로토콜**을 사용합니다.
대표적인 것이 **HLS(HTTP Live Streaming)**와 **DASH(MPEG-DASH)**입니다.
HLS는 Apple이 주도하여 개발한 스트리밍 방식으로,
미디어를 짧은 세그먼트로 쪼개어 전송하고 재생 플레이리스트(M3U)를 제공하는 형태입니다.
DASH는 MPEG에서 표준화한 비슷한 개념의 스트리밍입니다.
이러한 **적응형 스트리밍** 기술은 네트워크 상황에 맞춰 품질(비트레이트)을 조절할 수 있어 끊김 없이 재생하기에 유리합니다.
다만 **브라우저 지원**에 차이가 있는데,
Safari는 HLS를 네이티브로 지원하지만 다른 브라우저는 기본적으로는 지원하지 않아서
자바스크립트 라이브러리(`hls.js` 등)나
[Media Source Extensions(MSE) API](https://developer.mozilla.org/en-US/docs/Web/API/Media_Source_Extensions_API)를 통해 구현합니다.
MSE를 사용하면 분할된 미디어 데이터를 `<audio>`/`<video>` 요소에 공급할 수 있어 스트리밍을 직접 구현할 수 있습니다.
예를 들어 MSE로 MPEG-DASH 스트리밍을 파싱하여 `<audio>` 요소에 추가하면 브라우저가 이를 하나의 연속된 미디어로 취급해 재생합니다.

사용자가 `<audio>` 요소를 통해 오디오를 재생하면
브라우저는 해당 파일의 **MIME 타입**과 내용에 따라 **지원되는 코덱인지 판단**하고,
네이티브 디코더(브라우저 또는 OS 내장 코덱)를 이용해 **PCM 신호로 디코딩**합니다.
이 과정은 개발자가 신경쓰지 않아도 자동 처리됩니다.
그러나 개발자가 **오디오 데이터를 직접 조작하거나 시각화**하려는 경우,
**Web Audio API**의
[AudioContext.decodeAudioData()](https://developer.mozilla.org/en-US/docs/Web/API/BaseAudioContext/decodeAudioData)
등을 통해 ArrayBuffer 형태의 압축 오디오 데이터를 **수동으로 디코딩**할 수 있습니다.
아래 코드는 Fetch API로 가져온 오디오 파일을 Web Audio API로 디코딩한 후 재생하는 간단한 예시입니다.

```javascript
const audioContext = new AudioContext();
fetch("audio.mp3")
  .then(response => response.arrayBuffer())
  .then(arrayBuffer => audioContext.decodeAudioData(arrayBuffer))
  .then(audioBuffer => {
    const source = audioContext.createBufferSource();
    source.buffer = audioBuffer;
    source.connect(audioContext.destination);
    source.start();
  })
  .catch(error => console.error(error));
```

위 코드는 `sound.mp3`를 가져와 `AudioContext`로 디코딩한 뒤
[AudioBufferSourceNode](https://developer.mozilla.org/en-US/docs/Web/API/AudioBufferSourceNode)로 재생합니다.
이렇게 디코딩하면 **PCM 샘플 데이터에 직접 접근**할 수 있으므로,
오디오를 재생하기 전에 파형 데이터를 얻어 시각화하거나 이펙트를 적용하는 등 **세밀한 제어**가 가능합니다.
`decodeAudioData()`는 **Promise**를 반환하며,
브라우저의 내장 코덱을 사용하므로 `<audio>` 요소가 지원하는 포맷이면 디코딩이 성공합니다.

Web Audio API는 실시간 오디오 처리를 위해 별도의 스트리밍 메커니즘을 가지고 있습니다.
예를 들어 **마이크 입력**이나 기타 **MediaStream**을
Web Audio로 받아올 때
[AudioContext.createMediaStreamSource(stream)](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/createMediaStreamSource)를 사용하면
스트림이 [AudioNode](https://developer.mozilla.org/en-US/docs/Web/API/AudioNode)
체인으로 실시간으로 흘러들어오게 됩니다.
개발자는 일일이 버퍼를 관리하지 않아도 되며, Web Audio 엔진이 내부 버퍼링과 스트리밍을 처리해 줍니다.
따라서 [getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)로 받은 실시간 오디오나
`<audio>` 요소의 재생 음원을 Web Audio로 입력받아 **이펙트 처리 후 출력**하거나 **분석**할 수 있습니다.

요약하면, **짧은 파일 재생**은 그냥 `<audio>` 태그로 링크하는 것만으로 충분하고,
**긴 시간 재생**이나 **실시간/적응형 스트리밍**은 HLS/DASH + MSE 같은 방법을 사용합니다.
한편 **Web Audio API**를 사용하면
네이티브 미디어 요소보다는 더 저수준에서 스트리밍 제어와 디코딩 데이터를 다룰 수 있습니다.
다음으로 이렇게 전달된 오디오 데이터를 **브라우저에서 어떻게 출력하고 처리하는지** 살펴보겠습니다.

- **AudioContext와 AudioNode**: Web Audio를 사용하려면 먼저 `AudioContext`를 생성합니다.
  이 컨텍스트는 오디오 처리의 **작업공간**이며, 여기서 소스, 이펙트, 출력 노드를 연결합니다.
  예를 들어, 하나의 오디오 버퍼를 재생하려면 `audioCtx.createBufferSource()` 노드를 만들어 `audioCtx.destination` (기본 출력, 보통 스피커)에 연결합니다.
  또는 HTML 미디어 요소(`<audio>`/`<video>`)를 소스로 쓰고 싶다면 `audioCtx.createMediaElementSource(audioElement)`로 AudioNode를 얻어 이 역시 destination에 연결할 수 있습니다.
  즉, Web Audio로 `<audio>` 요소의 출력도 가로채 가공할 수 있습니다.
- **재생 제어**: `AudioBufferSourceNode`의 `start(when)` 메서드를 호출하면 재생이 시작됩니다.
  여러 소스를 동시에 `start()`하면 자동으로 믹싱되어 출력됩니다. Web Audio는 **내부적으로 부동소수점 PCM** 오디오 스트림을 처리하며, 각 노드는 일정 크기의 버퍼 단위로 신호를 전달합니다.
  개발자는 이러한 세부사항을 크게 신경쓰지 않아도 노드 연결만으로 실시간 처리가 가능하도록 추상화되어 있습니다.
- **오디오 파라미터**: Web Audio는 Gain(볼륨), Panner(좌우/3D 위치), BiquadFilter(필터 효과), Convolver(리버브) 등 다양한 **AudioNode**를 제공합니다.
  예를 들어 간단히 음량을 조절하려면 `GainNode`를 사용합니다. 다음과 같이 작성하면 소리 크기를 절반으로 줄여 출력할 수 있습니다.

```javascript
const gainNode = audioCtx.createGain();
source.connect(gainNode).connect(audioCtx.destination);
gainNode.gain.value = 0.5;
```

- **시각화 (AnalyserNode)**: 오디오 시각화는 Web Audio의 하이라이트 기능 중 하나입니다.
  `AnalyserNode`는 입력 신호의 **주파수 스펙트럼** 또는 **파형(time-domain) 데이터**를 실시간으로 제공합니다.
  `analyser.getByteFrequencyData()`로 FFT 기반 주파수 데이터를,
  `analyser.getByteTimeDomainData()`로 파형 샘플 데이터를 받으면,
  이를 Canvas나 WebGL로 그려서 **스펙트럼 애니메이션**, **오실로스코프 형태 파형 시각화** 등을 구현할 수 있습니다.
  이는 음악 플레이어의 이퀄라이저 비주얼이나, 마이크 음성 입력 레벨을 막대 그래프로 보여주는 등의 사례에 활용됩니다.
  Web Audio 기반으로 **주파수 분석**을 하면, 예를 들어 저음/고음의 세기를 측정해 조명 효과를 조절하거나 하는 **인터랙티브 비주얼**도 가능해집니다.
- **정밀 타이밍**: Web Audio API는 **고해상도 시계**를 사용하여 오디오 이벤트의 타이밍 정확도를 보장합니다.
  `AudioContext.currentTime`을 기준으로 노드의 `start()`를 미리 예약하면, 여러 소리를 밀리초 단위로 정밀하게 동기화할 수 있습니다.
  이는 `<audio>` 요소의 JavaScript 타이밍 제어보다 정확도가 높아, 음악 애플리케이션이나 리듬 게임 등에서 유용합니다.

Web Audio API의 유연성 덕분에, **게임 오디오**, **뮤직DAW 웹앱**, **오디오 시각화 데모** 등 수많은 응용이 웹에서 가능해졌습니다.
다만 Web Audio API를 사용할 때에도, 브라우저의 미디어 코덱 지원 범위 내에서 소스를 가져와야 함은 동일합니다 (즉, `decodeAudioData`로 디코딩 가능해야 함).
그리고 Web Audio는 **사용자 승인 없이 임의로 소리를 재생하지 못하도록** 브라우저의 **autoplay 정책** 영향을 받습니다.
따라서 AudioContext를 만들어 소스를 `start()`하는 것도 사용자가 클릭 등 **인터랙션한 맥락 내**에서 이루어져야 합니다.
이에 대해서는 아래 **브라우저의 미디어 정책**에서 추가로 다룹니다.

# 마이크 입력과 녹음: MediaDevices 및 MediaRecorder

이제 오디오의 **입력** 측면을 살펴보겠습니다.
[getUserMedia API](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)를 통해
사용자의 오디오 입력을 웹 애플리케이션으로 가져올 수 있고,
이렇게 들어온 오디오를 실시간 처리하거나 녹음하여 파일로 저장할 수 있습니다.
웹에서 오디오 입력/녹음의 기본 흐름은 다음과 같습니다.

1. **MediaDevices.getUserMedia()** 로 **마이크 접근 권한**을 요청하여 **MediaStream**을 얻는다.
2. 얻어진 MediaStream을 **Web Audio API**에 연결하거나, **MediaRecorder**로 기록하거나, 혹은 `<audio>` 요소로 바로 들려줄 수도 있다.
3. **Web Audio API**를 사용하면 입력 신호에 필터나 이펙트를 걸거나 시각화할 수 있으며, MediaRecorder를 사용하면 실시간으로 스트림을 인코딩하여 Blob 데이터로 축적할 수 있다.
4. MediaRecorder로 녹음된 오디오 파일을 Blob으로 다운로드하거나, `URL.createObjectURL()` 등을 통해 `<audio>`로 재생할 수 있다.

순서대로 조금 더 상세히 설명합니다.

## MediaDevices.getUserMedia()로 오디오 입력 받기

`navigator.mediaDevices.getUserMedia(constraints)` 메서드는 사용자에게 **마이크나 카메라 사용 권한**을 요청하고,
승인되면 해당 **MediaStream** (오디오/비디오 흐름 객체)을 반환합니다.
오디오만 필요하다면 `constraints` 파라미터로 `{ audio: true, video: false }` 또는 `{ audio: true }` 만 전달하면 됩니다.
이 API는 **프라미스(Promise)** 기반이며, 성공 시 `MediaStream`을, 실패 시 에러를 줍니다.

```javascript
try {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
  console.log("마이크 스트림 얻기 성공:", stream);
} catch(err) {
  console.error("마이크 스트림 얻기 실패:", err);
}
```

이때 브라우저는 처음 호출 시 사용자의 **허용/거부** 동의를 묻는 팝업을 표시합니다.
또한 **보안상의 이유로 getUserMedia는 SSL 환경(HTTPS)**에서만 동작합니다.
(로컬 개발에서는 `localhost`나 `file://`도 허용됩니다.)
사용자가 허용했다면 `MediaStream`에는 하나 이상의 **MediaStreamTrack**이 포함되는데, 오디오만 요청한 경우 보통 하나의 오디오 트랙이 있습니다.

## Web Audio API로 입력 스트림 처리하기

얻은 `MediaStream`은 다양한 용도로 활용할 수 있습니다.
우선, **실시간 처리**를 위해 Web Audio API와 연계하는 방법부터 보겠습니다.
Web Audio API는 `MediaStreamAudioSourceNode`를 통해 외부 스트림을 오디오 노드 그래프로 끌어들일 수 있습니다.
`AudioContext.createMediaStreamSource(stream)`을 호출하면 해당 스트림을 소스로 가지는 AudioNode를 얻습니다.
이를 다른 노드에 연결하여 실시간 처리를 시작할 수 있습니다.

**예시**: 마이크 입력을 받아 Web Audio로 **시각화 및 출력**해보겠습니다.

```javascript
const audioCtx = new AudioContext();
const sourceNode = audioCtx.createMediaStreamSource(stream);  // 마이크 MediaStream을 AudioNode로 변환
const analyser = audioCtx.createAnalyser();
sourceNode.connect(analyser);
sourceNode.connect(audioCtx.destination);
```

위 코드에서 마이크 스트림으로부터 `sourceNode`를 만들고, 이것을 `AnalyserNode`와 오디오 출력(`destination`)에 연결했습니다.
이렇게 하면 사용자가 말하는 소리가 곧바로 스피커로 출력됨과 동시에 `analyser` 노드를 통해 주파수 데이터 등을 획득할 수 있습니다.
(`audioCtx.destination`은 기본 출력 장치, 즉 스피커를 의미합니다.)

> Tip: 마이크를 실시간 출력하면 사용자에게 자신의 목소리가 약간 지연되어 들리는데, 이를 사운드 모니터링이라고 합니다.
> 보통 수백 ms 이하의 지연이지만, 이 딜레이 때문에 약간 어색하게 들릴 수 있습니다.
> 전문 오디오 장비 없이 웹에서 완전 무지연 모니터링은 어려우므로, 필요할 때만 출력하거나, 헤드폰 사용을 권장해야 합니다.
> 또한 sourceNode.connect(audioCtx.destination) 부분을 빼면 모니터링 없이 무음으로 입력 처리를 할 수 있습니다 (분석이나 녹음만 할 때 유용).

이처럼 Web Audio를 사용하면 입력 신호에 대해 **실시간 분석**(AnalyserNode 활용)이나 **이펙트 적용**(예: GainNode로 증폭/감쇠, BiquadFilterNode로 노이즈 제거 등)이 가능합니다.
가령 간단한 **VU 미터**(볼륨 레벨 표시)를 구현하려면 각 애니메이션 프레임마다
`analyser.getByteTimeDomainData()`로 웨이브폼 데이터를 가져와 그 **평균 진폭**이나 **최대치**를 계산, 이를 그래프로 그리면 됩니다.

## MediaRecorder를 사용한 오디오 녹음

마이크에서 들어온 `MediaStream`을 파일로 저장하려면 **MediaStream Recording API**,
즉 [MediaRecorder](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder)를 사용하면 됩니다.
MediaRecorder는 MediaStream을 받아 해당 스트림을 **지정한 코덱으로 실시간 인코딩**하여 **블랍(Blob)**으로 축적해 줍니다.
스트림에는 비디오가 포함될 수도 있지만 여기서는 오디오 스트림으로 한정해 설명합니다.

MediaRecorder 사용 방법은 간단합니다.

```javascript
const recorder = new MediaRecorder(stream, { mimeType: "audio/webm" });  // 또는 audio/ogg 등
const chunks = [];
recorder.ondataavailable = e => chunks.push(e.data);
recorder.onstop = e => {
  const blob = new Blob(chunks, { type: recorder.mimeType });
  console.log("녹음 완료 Blob:", blob);
};
recorder.start();
// ... 필요 시 recorder.stop() 호출
```

위 코드에서, `MediaRecorder(stream)`으로 recorder를 생성할 때 `{ mimeType: "audio/webm" }`과 같이 원하는 출력 컨테이너와 코덱의 MIME 유형을 지정할 수 있습니다.
지정하지 않으면 **브라우저 기본값**으로 인코딩됩니다 (예를 들어 Chrome은 기본적으로 `audio/webm` Opus, Firefox는 `audio/ogg` Opus 등).
`recorder.start()`를 호출하면 녹음이 시작되고, 이어서 `dataavailable` 이벤트가 발생할 때마다 `chunks` 배열에 Blob 조각을 모읍니다.
`MediaRecorder`는 내부적으로 일정 간격마다 데이터를 내보내는데, `start(timeslice)`에 밀리초 단위로 값을 주면 해당 간격마다 `dataavailable` 이벤트를 받을 수 있습니다.
또는 `recorder.requestData()`를 호출해서 수동으로 현재까지의 데이터를 받을 수도 있습니다.

녹음을 중지하려면 `recorder.stop()`을 호출합니다.
그러면 마지막 데이터 조각과 함께 `stop` 이벤트가 발생하고, 그 시점에 우리가 모은 `chunks`들을 합쳐 하나의 Blob을 만들 수 있습니다.
위 코드의 `onstop` 핸들러는 Blob을 생성하고 있습니다.
이렇게 얻은 Blob 객체를 다룰 방법은 여러 가지가 있습니다:

- `URL.createObjectURL(blob)`으로 객체 URL을 만든 뒤, 이를 `<audio>` 요소의 `src`로 설정하면 녹음한 내용을 **즉시 재생**해볼 수 있습니다. (예: `audioElem.src = URL.createObjectURL(blob)`).
- 서버로 Blob을 업로드하여 저장하거나, `<a>` 태그의 `href`에 객체 URL을 넣고 `download` 속성을 주어 **파일 다운로드** 링크를 제공할 수도 있습니다.
- Blob을 `File` 객체로 변환하거나, FileReader로 읽어 ArrayBuffer/데이터URL로 변환해 처리할 수도 있습니다.

**MediaRecorder의 코덱**: `MediaRecorder.mimeType`으로 현재 녹음에 사용된 실제 MIME 정보를 알 수 있습니다.
브라우저별로 지원하는 MIME 타입이 다를 수 있으므로, `MediaRecorder.isTypeSupported()` 정적 메서드로 **사용 가능 여부**를 사전에 확인하는 것이 좋습니다.
예를 들어 Safari는 과거 `audio/webm`을 지원하지 않았고 `audio/mp4` (AAC) 형태로만 작동한 적이 있으므로, 호환성을 위해 조건 분기를 둘 수 있습니다.
기본적으로 Chrome/Firefox/Edge 등은 `audio/webm;codecs=opus`나 `audio/ogg;codecs=opus`를 지원하며, 대부분 Opus 코덱으로 녹음됩니다.
Opus는 음성/음악 모두에 적합한 현대적인 코덱이고, 브라우저가 알아서 인코딩을 최적화해주므로 개발자는 신경쓸 부분이 적습니다.

**예시**: 사용자가 버튼을 눌러 녹음을 시작/정지하고, 녹음된 파일을 리스트에 추가하여 재생할 수 있게 하는 간단한 활용은 다음과 같은 흐름입니다.

```javascript
recorder.start();
// ... 녹음 진행중, UI에 녹음중 표시
recorder.ondataavailable = e => { chunks.push(e.data); };

recorder.onstop = () => {
  const blob = new Blob(chunks, { type: recorder.mimeType });
  chunks.length = 0;
  const clipURL = URL.createObjectURL(blob);
  // 새로운 <audio> 요소 동적으로 생성하여 clipURL을 src로 설정, 리스트에 추가
};
```

위 로직을 이용하면 사용자가 여러 음성 클립을 녹음하여 순차적으로 플레이하거나 삭제할 수 있는 간단한 **웹 보이스 레코더**를 만들 수 있습니다.
실제 MDN의 Web Dictaphone 예제가 이와 동일한 아이디어로 구현되어 있으며, 녹음된 Blob을 `<audio>`로 추가하고, 이름을 붙이고, 삭제 버튼을 다는 등의 UI를 보여줍니다.

MediaRecorder API의 편의성 덕분에, 별도 서버없이도 **클라이언트 사이드**에서 오디오 녹음 기능을 쉽게 제공할 수 있습니다.
다만, **Mobile Safari** 등 일부 환경에서는 MediaRecorder 지원이 늦게 이루어졌으므로 (iOS 14+ 지원 등), 사용자 플랫폼에 따라 폴백 전략이 필요할 수 있습니다.
폴백으로는 Flash 기반 솔루션(과거)이나, Web Audio로 입력을 받아 manually WAV로 인코딩하는 방법(성능 부담 큼) 등이 있을 수 있지만, 최근에는 대부분 브라우저에서 MediaRecorder를 지원합니다.

## Web Audio와 MediaRecorder의 조합

여기까지 마이크 입력을 실시간 처리(Web Audio)하거나 파일로 저장(MediaRecorder)하는 방법을 개별적으로 살펴봤습니다.
실제로는 이 둘을 **조합**하여, **실시간 처리된 오디오를 녹음**하거나 하는 것도 가능합니다.
예를 들어 **노이즈 필터**를 Web Audio로 적용한 뒤 깨끗해진 신호를 녹음하거나, 여러 오디오 소스를 믹싱한 결과를 하나의 스트림으로 녹음하는 경우입니다.

이를 위해 Web Audio API는 `AudioContext.createMediaStreamDestination()` 노드를 제공합니다.
이 노드는 AudioNode 그래프의 출력을 **MediaStream으로 변환**해줍니다.
`const dest = audioCtx.createMediaStreamDestination();`를 호출하면 얻어지는 `dest.stream`은 MediaStream으로서, 여기에는 AudioContext에서 만들어진 모든 소리가 실시간 포함됩니다.
이 스트림을 앞서처럼 `new MediaRecorder(dest.stream)`에 넘기면 Web Audio 출력 자체를 녹음할 수 있습니다.
이렇게 하면 **효과 처리 후의 오디오**나 **다중 소스 믹스**를 녹음하는 것이 가능해집니다.

예를 들어, 마이크 입력에 에코 효과를 주고 싶은 경우 다음과 같이 구현할 수 있습니다.

```javascript
const sourceNode = audioCtx.createMediaStreamSource(stream);
const echo = audioCtx.createDelay(0.3);
sourceNode.connect(echo).connect(audioCtx.destination); // 출력 (에코 포함)
sourceNode.connect(echo).connect(dest);                 // MediaStreamDestination에도 연결
const recorder = new MediaRecorder(dest.stream);
```

위에서 `dest`는 `createMediaStreamDestination()`으로 만든 것이고, 이 dest.stream을 녹음하면 에코가 섞인 마이크 소리가 파일로 저장됩니다.
이처럼 Web Audio와 MediaRecorder를 조합하면 **자유로운 오디오 파이프라인** 구성이 가능하며, 웹에서 간단한 **DAW(Digital Audio Workstation)** 기능 흉내까지 낼 수 있습니다.

# 브라우저의 오디오 재생 정책

웹에서 오디오를 다룰 때는 브라우저 정책들을 알아두어야 합니다.
대표적으로 **autoplay 차단**과 **사용자 권한 요구**,
그리고 오디오 관련 **보안 이슈**가 있습니다.

현대 브라우저들은 사용자의 의도 없이 웹페이지가 함부로 소리를 재생하지 못하도록 **자동 재생을 차단**하는 정책을 가지고 있습니다.
*"Autoplay"*란 **사용자 조작 없이 자동으로 재생이 시작되는 것**을 말하며, HTML 속성이나 JS로 플레이를 트리거하는 모든 경우를 포함합니다[^4].
일반적으로 **사용자가 페이지와 상호작용(예: 클릭, 키누름)하기 전까지**는 audio/video의 재생을 시작할 수 없습니다.
예를 들어 `<audio autoplay>`로 설정해도 무음이 아닌 이상 대기 상태에 머물다, 사용자가 화면을 터치하거나 클릭하면 그제서야 재생됩니다.
Web Audio API에서도 `AudioBufferSourceNode.start()` 등을 사용자 gesture 없이 호출하면 재생이 안되고 AudioContext가 **suspended** 상태로 머무를 수 있습니다.
이러한 정책은 브라우저마다 구현 세부사항은 다르지만(일부는 무음인 경우 허용 등), **공통적으로 사용자 경험을 해치지 않기 위한 조치**입니다. 개발자는 **사용자 액션 시점에 재생을 시작**하도록 유도하는 것이 좋습니다.
예를 들어 "재생" 버튼을 제공하고 그 클릭 핸들러 안에서 `audio.play()`나 Web Audio `context.resume()`/`start()`를 호출하면 대부분 문제없이 동작합니다.
반대로, 페이지 로드시 배경음악을 자동틀도록 설계하면 사용자 동의 없이는 소리가 안 날 가능성이 높습니다.
만약 반드시 자동 재생이 필요한 경우 (예: 웹 게임의 배경음 등), 첫 사용자 진입 때 **mute(음소거) 상태로 자동 재생**을 해두고 "소리 켜기" 버튼을 눌러야만 음소거를 해제하는 방식을 쓸 수도 있습니다.
이렇게 하면 무음 재생은 허용되는 브라우저에서 사전에 오디오 스트림을 준비해 둘 수 있는 장점이 있습니다.

**getUserMedia**는 민감한 개인정보(목소리)를 다루므로 **반드시 사용자 허가**가 필요합니다.
사용자가 한번 허용하면 권한이 일정 기간(또는 세션 등) 기억될 수 있지만,
**https**가 아닌 경우 아예 동작하지 않으며,
iframe 등에서는 추가적인 `allow` 속성 설정(`allow="microphone"`)이 필요할 수 있습니다.
이렇듯 **마이크/카메라 접근에는 권한 정책**을 따라야 합니다.
음성 녹음 데이터를 서버로 전송할 경우에도 **사용자 프라이버시**에 대한 고지와 정책 준수가 필요합니다.

또 다른 권한 이슈로 **AudioContext의 출력 장치 선택**이 있습니다.
기본적으로 오디오는 시스템 기본 출력(스피커 등)으로 나가지만,
Chrome 등의 일부 브라우저는 [selectAudioOutput() API](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/selectAudioOutput)로
출력 디바이스를 지정할 수 있게 합니다.
이것도 [사용자 권한](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/selectAudioOutput#security_requirements)이 필요합니다.

`<audio>` 태그로 외부 도메인 리소스를 가져올 때 **CORS** 이슈는 일반적으로 없지만,
Web Audio API로 XHR/Fetch를 통해 오디오 파일을 가져와
`decodeAudioData`로 디코딩하려면 **CORS 허용 헤더**가 필요합니다.
이것은 다른 이미지/JS 불러오는 것과 비슷합니다.

# 오디오 성능

Web Audio API는 `AudioContext` 생성 시
[{ latencyHint: 'interactive' }](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext/AudioContext#latencyhint) 등으로 힌트를 줄 수 있지만,
실제 지연은 기기와 브라우저에 따라 달라집니다.
일반적으로 20~50ms 정도 출력 지연은 감안해야 하며,
`MediaRecorder`로 녹음할 때도 수십 ms 단위 버퍼링이 있습니다.
Voice chat 등의 경우 WebRTC를 쓰지만, 만약 Web Audio만으로 구현한다면 이 지연에 유의해야 합니다.
또한 오디오 처리는 CPU 부하를 줄 수 있으므로 다음과 같은 최적화도 고려하면 좋습니다.

- 분석/시각화 연산을 너무 짧은 주기로 하지 않기
- 필요 이상으로 많은 노드 사용 자제
- 오디오 처리를 담당하는 함수에서는 불필요한 DOM 접근 피하기

# 결론

웹에서 오디오를 입력부터 출력까지 다루는 과정을 살펴보았습니다.
**오디오 포맷과 코덱**의 개념을 이해함으로써 어떤 형식의 오디오를 제공해야 할지 판단할 수 있고,
**스트리밍과 디코딩 방식**을 알면 다양한 시나리오 (로컬 재생, 라이브 스트리밍 등)에 대응할 수 있습니다.
또한 **getUserMedia + Web Audio API**를 통해 **실시간 오디오 처리와 시각화**를 구현하고,
**MediaRecorder**를 이용해 그 결과를 저장하거나 전송하는 방법도 익혔습니다.
요즘 브라우저들은 데스크톱이든 모바일이든 풍부한 오디오 관련 API를 제공하며,
이것들을 조합하면 웬만한 오디오 응용 프로그램을 웹으로 구현할 수 있을 정도입니다.

마지막으로, 웹 오디오를 다룰 때는 항상 **사용자의 권한과 환경을 존중**하는 것이 중요합니다.
자동으로 소리가 재생되지 않게 하고, 녹음 시 명확한 안내를 제공하며,
최적의 포맷을 선택해 **끊김없고 품질 좋은 사운드 경험**을 제공하길 바랍니다.
이 가이드가 웹 오디오 파이프라인을 이해하고 활용하는 데 도움이 되었기를 바랍니다.
필요한 경우 MDN의 관련 문서와 각종 예제를 참고하여 더 깊이있는 구현으로 나아가 보세요.

# 더 읽을 거리

- [Web Audio API - code examples](https://github.com/mdn/webaudio-examples) | MDN GitHub
- [Getting started with Web Audio API](https://web.dev/articles/webaudio-intro) | web.dev
- [Encoding and decoding audio - Audio Toolbox](https://developer.apple.com/documentation/audiotoolbox/encoding-and-decoding-audio) | Apple Developer
- [Streaming audio and video](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Streaming) | MDN
- [Using the MediaStream Recording API](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream_Recording_API/Using_the_MediaStream_Recording_API) | MDN

[^1]: [Digital audio concepts](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Audio_concepts) | MDN
[^2]: [Web audio codec guide](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Audio_codecs) | MDN
[^3]: [Cross-browser audio basics](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Audio_and_video_delivery/Cross-browser_audio_basics) | MDN
[^4]: [Autoplay guide for media and Web Audio APIs](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Autoplay) | MDN
