---
draft: false
socialshare: true
date: 2024-12-10T22:46:00+09:00
lastmod: 2024-12-15T23:30:00+09:00
title: "파일 시그니처와 파일 카빙: 바이너리 데이터가 이상한 문자열로 표현되는 이유"
description: "파일 포맷, 데이터의 저장과 표현"
featured_image: "/images/reverse-engineering/file-signature/pexels-markusspiske-1089438.jpg"
images: ["/images/reverse-engineering/file-signature/pexels-markusspiske-1089438.jpg"]
tags:
  - reverse-engineering
  - file-signature
  - file-carving
categories:
  - wiki
---

# 개요

이미지를 다운로드하면 응답 데이터로 이상한 문자열이 출력됩니다.

```sh
# Youtube의 빈 썸네일 이미지를 다운로드 받습니다.
curl -L -o - https://i.ytimg.com/
```

```sh
����JFIF���

�      !�
!"12ARaBqr��U�����������Qbd�������
                                  ?�@��t��2�4�2�4��&`�f�b��*)��6�j�pVZ7՚�ތC:#uf��§���<�Z�W
�oMku�@��<\�O����H����M?^_��n
                             Z��W�:>vW���ҟ˃lr�h�8e�z*ڷ�zw�ie4�
e�C�#:=(���R�'F��0���e�
                       �
                        ���T���9�p�z�n/1
                                        �mSV��t�V�"��U �MI�;w��{O%��q
                                                                     �[$x�7UV��⫫�t����=6�l�`Si)u7	u�^z*UW��[���L�˭��a?
                                                                                                                            yn��mN���K��:��Z��&_
                                                                                                                                                ���{
  ����j�sj�j-T���U�^m�2\�O7��M�{�V�v��Vݝz�ԞRe|8��?�4qL5�i��Z��V�2e�ʝ��'����%zV����v�8
.A.@��F���>�8]�JU��ҕj�z�Vb~��o)*�Ҍ������/�n���{m�Ա��vI��U�qoZ�+U��Z{�&Z��;��B�������k�XЏR�;*t��	|J�-���ku�Kk5_s�[8�te��d�kĮl��%�{]�i���ɩ{5}%Y���in��sYa��*�ɭ��߯ko>��� f��,[��ٷ�h��?X|Yg�j?��1���s��t��� HJ�
                                             �^�f�4��Vނu-m�շ�����`l���^���U{
                                                                            &H��%
```

�는 유니코드 replacement character(`U+FFFD`)로, 해석할 수 없는 문자를 표시하기 위해 사용됩니다.

이번엔 hexdump로 만들어주는 `xxd` 명령어를 파이프로 이어보겠습니다.

```sh
whatis xxd
# xxd (1)              - make a hexdump or do the reverse.
```

```sh
curl -L -o - https://i.ytimg.com/ | xxd
```

뭔지 모르겠지만 응답 데이터 앞쪽에 `JFIF`가 적혀있습니다.
JFIF 파일 포맷일까요?
이후엔 또 알 수 없는 문자열이 출력됩니다.

```sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1097  100  1097    0     0   4712      0 --:--:-- --:--:-- --:--:--  4728
00000000: ffd8 ffe0 0010 4a46 4946 0001 0100 0001  ......JFIF......
00000010: 0001 0000 ffdb 0084 0005 0304 0705 0705  ................
00000020: 0505 0506 0508 0506 0505 0505 0805 0507  ................
00000030: 0508 0505 0509 0608 0905 0513 0a1c 0b07  ................
00000040: 081a 0908 050e 2118 1a1d 111f 131f 130b  ......!.........
00000050: 2218 221e 181c 1213 1201 0505 0507 0607  ".".............
00000060: 0508 0805 1208 0508 1212 1212 1212 1212  ................
00000070: 1212 1212 1212 1212 1212 1212 1212 1212  ................
00000080: 1212 1212 1212 1212 1212 1212 1212 1212  ................
00000090: 1212 1212 1212 1212 1212 ffc0 0011 0800  ................
000000a0: 5a00 7803 0122 0002 1101 0311 01ff c400  Z.x.."..........
000000b0: 1b00 0100 0203 0101 0000 0000 0000 0000  ................
000000c0: 0000 0001 0402 0307 0605 ffc4 003d 1000  .............=..
000000d0: 0201 0203 0307 060d 0500 0000 0000 0000  ................
000000e0: 0201 0304 0511 1206 1321 0722 3132 4152  .........!."12AR
000000f0: 6114 4271 7292 d215 5581 8491 94b1 c1c2  a.Bqr...U.......
00000100: c3d1 d3f0 1751 6264 b3ff c400 1401 0100  .....Qbd........
00000110: 0000 0000 0000 0000 0000 0000 0000 00ff  ................
00000120: c400 1411 0100 0000 0000 0000 0000 0000  ................
00000130: 0000 0000 00ff da00 0c03 0100 0211 0311  ................
00000140: 003f 00ef 4000 0000 0098 8274 8188 32d0  .?..@......t..2.
00000150: 3401 8832 d034 8188 2660 8000 0000 0000  4..2.4..&`......
00000160: 0010 66aa 62a5 8a2a 0129 1b96 81f2 3683  ..f.b..*.)....6.
00000170: 6aec 7056 5a37 1bda d59a 15da de8c 433a  j.pVZ7........C:

...

000003b0: 495a 369b c7de cae4 af5a 5251 1297 7a63  IZ6......ZRQ..zc
000003c0: 5673 97de 74ba 8c06 a620 4800 0000 0000  Vs..t.... H.....
000003d0: 4ac9 000d 9ab5 7359 61a3 bb2a b31e c9ad  J.....sYa..*....
000003e0: adad dfaf 6b6f 3eb5 bd19 fc20 6606 a6c3  ....ko>.... f...
000003f0: 2c5b ad87 d9b7 cd68 fba6 3f04 587c 5967  ,[.....h..?.X|Yg
00000400: f56a 3fa1 bf31 981a d70c b25e ae1f 66bf  .j?..1.....^..f.
00000410: 34a3 ee9b 56de 8275 2d6d d3d5 b7a2 bf84  4...V..u-m......
00000420: 8cc6 606c 97ec ec5e aac7 058f 557b 0c26  ..`l...^....U{.&
00000430: 4800 0000 0000 0000 0000 0000 0000 0000  H...............
00000440: 0000 0000 0000 7fff d9                   .........
```

이는 이진(binary) 데이터를 16진수(hexadecimal) 혹은 터미널, 브라우저와 같은 실행 프로그램에서 지원하는 문자열로 표현된 것입니다.

이번엔 HTML 문서를 PDF로 변환해서 응답하는 서버로 테스트 해보겠습니다.
[데모 서버](https://github.com/markruler/htmltopdf)를 실행 후
다음과 같은 코드로 요청을 보내면 PDF 파일을 받을 수 있습니다.

```javascript
let myHeaders = new Headers();
myHeaders.append("Content-Type", "application/x-www-form-urlencoded");

let urlencoded = new URLSearchParams();
urlencoded.append("html", "<div><span>Test</span> Text</div>");
urlencoded.append("css", "span{color:red;}span{font-size:30px;}");
urlencoded.append("orientation", "landscape");
urlencoded.append("filename", "test-filename");

let requestOptions = {
  method: 'POST',
  headers: myHeaders,
  body: urlencoded,
  redirect: 'follow'
};

fetch("/pdf/content", requestOptions)
  .then(response => response.text())
  .then(result => console.log(result))
  .catch(error => console.log('error', error));
```

`console.log()`로 출력된 응답 데이터는 `%PDF`라는 문자를 시작으로 다양한 형식의 데이터가 혼합되어 있습니다.
PDF 형식이라는 것을 유추할 수 있습니다.
반면 네트워크 패널에서 응답(Response) 데이터는 16진수로 표현됩니다.[^1]

[^1]: [Memory Inspector](https://developer.chrome.com/docs/devtools/memory-inspector)가 네트워크 패널에도 적용된 것으로 보입니다.

![Hexadecimal PDF](/images/reverse-engineering/file-signature/hex-pdf.png)

크롬 브라우저는 그동안 네트워크 패널에서 바이너리 데이터를 응답받으면
"The request has no response data available."이라는 메시지와 함께 표시하지 않거나 UTF-8로 디코딩하여 출력했습니다.
최근 업데이트[^2] 이후 16진수로 표현하도록 변경되었습니다.

[^2]: 정확히 언제인지는 모르겠지만 Google Chrome 131 전후로...

![google-chrome-123.0.6312.122-network-img-response](/images/reverse-engineering/file-signature/google-chrome-123.0.6312.122-network-img-response.png)

크롬의 Preview 탭은 해당 파일 포맷에 맞게 미리보기가 출력됩니다.

![google-chrome-123.0.6312.122-network-img-preview](/images/reverse-engineering/file-signature/google-chrome-123.0.6312.122-network-img-preview.png)

그렇다면 이 괴상한 문자열들은 어떻게 해석해야 할까요?

# 파일 시그니처

파일 시그니처(File Signature)는 파일의 특정 부분에 위치한 고유한 바이트 패턴입니다.
파일이 어떤 포맷인지 알려주는 식별자 역할을 합니다.
매직 넘버(magic numbers)라고도 부르죠.

실행 프로그램(Reader)들은 파일 시그니처를 확인하여 파일 포맷을 판별하고,
해당 파일 포맷에 맞게 데이터를 해석하고 표현합니다.
가장 먼저 봤던 `JFIF` 파일이나 `%PDF` 모두 파일의 앞쪽에 위치하는 헤더 시그니처입니다.
(모든 파일 형식이 이름과 동일하게 시그니처를 정하진 않습니다.)

파일의 시그니처를 확인하는 번거로운 작업을 줄이기 위해
웹에서는 응답 헤더에 "Content-Type"을 지정하고
GUI 환경 데스크탑에서는 "파일 확장자(File Extension)"를 지정합니다.

# 파일 카빙

파일 카빙(File Carving)은 파일 시그니처 기반으로 저장 매체에서 파일 내용을 복구하는 기술입니다[^3].

[^3]: [(Youtube) 삭제 파일 복구 기술](https://youtu.be/60FtdnBey-E?list=PLx4zTdLSy3x7wBShSxO-gykGUPrH1LF4L&t=745) - DFRC (Digital Forensic Research Center)

- [DFRC (Digital Forensic Research Center)](https://dfrc.korea.ac.kr/) 자료를 참조했습니다.
  - [파일 복구](https://web.archive.org/web/20180815025824/http://forensic.korea.ac.kr/DFWIKI/index.php/%EB%8D%B0%EC%9D%B4%ED%84%B0_%EB%B3%B5%EA%B5%AC)
  - [램 슬랙](https://youtu.be/URsDgiD0FwA?list=PLx4zTdLSy3x7wBShSxO-gykGUPrH1LF4L&t=1657)

## 1. 시그니처 기반 카빙

- 주요 과정
  - header 시그니처 탐지: 저장 매체의 로우 데이터(raw data)에서 파일 헤더 시그니처를 검색합니다.
  - footer 시그니처 탐지: 같은 방식으로 파일의 푸터 시그니처를 검색합니다.
  - 데이터 추출: 헤더 시그니처와 푸터 시그니처 사이의 데이터를 추출하여 파일로 복원합니다.
  - 파일 검사 및 재구성: 복원된 파일의 무결성과 유효성을 검사하여 제대로 복구되었는지 확인합니다.
- 한계점
  - 조각난 파일(Fragmented File): 파일이 여러 조각으로 분리되어 저장된 경우 복구가 어렵습니다.
  - 파일 손상: 데이터 일부가 손실되었거나 덮어씌워진 경우 복원이 불완전할 수 있습니다.
  - 정확도: 잘못된 시그니처 탐지로 인해 오탐(False Positive)이 발생할 수 있습니다.

## 2. 파일 구조체 카빙

파일의 내부 구조를 분석하고 검증하여 파일을 복구합니다.

- 파일 미리보기 지원하는 파일은 파일 포맷 내부에 실제 내용과 썸네일(Thumbnail)을 포함하는데,
  썸네일도 해당 파일 포맷과 동일한 구조로 되어 있어 시그니처가 2개 이상 존재합니다.
- ZIP 파일의 경우 헤더 시그니처가 `PK34`(hex: `50 4B 03 04`)이며, 푸터 시그니처가 `PK56`(hex: `50 4B 05 06`) 입니다.
  파일 헤더에는 파일 크기와 CRC32 체크섬이 포함된 메타데이터가 있습니다.
  단편화된 파일을 재구성하는 경우 파일 구조를 바탕으로 데이터 블록을 논리적으로 연결합니다.
  이후 메타데이터에서 체크섬을 검증하여 파일의 무결성을 확인합니다.

## 3. 램 슬랙 카빙

파일의 내용을 디스크에 기록할 때 파일 크기가 512의 배수가 되지 않으면 `0x00`으로 채워지는 영역을 램 슬랙이라고 합니다.
디스크 섹터의 크기가 512 bytes일 때 파일의 크기가 512의 배수가 아닌 경우 나머지 부분은 램 슬랙으로 채워집니다.
시그니처 기반 카빙 기법에서 푸터 시그니처와 함께 램 슬랙을 확인하게 되면 많은 오탐을 줄일 수 있습니다.

# 더 읽을거리

- [(Youtube) 디지털 데이터의 저장과 표현: 문자 코드와 파일](https://youtu.be/M-_Fdgf9IZo?list=PLx4zTdLSy3x7wBShSxO-gykGUPrH1LF4L) - DFRC (Digital Forensic Research Center)
- [GCK'S FILE SIGNATURES TABLE](https://www.garykessler.net/library/file_sigs.html)
- [List of file signatures](https://en.wikipedia.org/wiki/List_of_file_signatures) - Wikipedia
- [The concept of file signatures recovery](https://www.file-recovery.com/signatures.htm) - Active@ File Recovery
