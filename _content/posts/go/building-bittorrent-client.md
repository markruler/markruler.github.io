---
date: 2020-12-28T14:46:00+09:00
lastmod: 2020-12-28T14:46:00+09:00
title: "Go로 밑바닥부터 만드는 BitTorrent 클라이언트"
description: "Jesse Li"
# featured_image: "/images/go/bit-torrent/2001-bit-torrent.png"
images: ["/images/go/bit-torrent/2001-bit-torrent.png"]
socialshare: true
tags:
  - bittorrent
  - go
  - translate
categories:
  - wiki
---

> - [Jesse Li의 Building a BitTorrent client from the ground up in Go (2020-01-04)](https://blog.jse.li/posts/torrent/)를 번역한 글입니다.
> - 저자의 허락을 받고 번역했습니다.

**거두절미(tl;dr):** The Pirate Bay를 방문하고 mp3 파일이 나타나기까지 무슨 일이 일어나는 것일까요?
이 글에서는 데비안(Debian)을 다운로드할 수 있을 정도의 비트토렌트 프로토콜을 구현할 것입니다.
바로 [소스 코드](https://github.com/veggiedefender/torrent-client/)를 보거나 [마지막 부분](#모두-합치기)으로 넘어갈 수 있습니다.

비트토렌트(BitTorrent)는 인터넷을 통해 파일을 다운로드하고 배포하기 위한 프로토콜입니다.
다운로더가 중앙 서버와 연결하는 기존의 클라이언트/서버 관계 (예: 넷플릭스에서
영화를 보거나 지금 읽고 있는 웹 페이지를 불러 오는 것)와 달리,
**피어(peer)** 라고 불리는 비트토렌트 네트워크 참여자들은 *서로에게서* 파일 조각을 다운로드합니다.
이것이 **P2P(peer-to-peer)** 프로토콜입니다.

![client-server-p2p](/images/go/bit-torrent/client-server-p2p.png)

이 프로토콜은 지난 20년 동안 진화했으며, 다양한 사람들과 조직들이 암호화(encryption),
비공개 토렌트(private torrent), 새로운 피어 탐색법과 같은 기능들을 추가했습니다.
우리는 주말에 구현할 수 있을 정도의 프로젝트 사이즈로 만들기 위해 [2001년 규격](https://www.bittorrent.org/beps/bep_0003.html)을 구현할 것입니다.

저의 실험 재료로 적당한 350MB의 [데비안 ISO](https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/#indexlist) 파일을 사용하겠습니다.
널리 사용되는 리눅스 배포판은 빠르고 협력적인 피어들이 많이 연결될 것입니다.
그리고 불법 복제 콘텐츠 다운로드와 관련된 법적, 윤리적 문제를 피할 수 있습니다.

# 피어 찾기

다음과 같은 문제가 있습니다. 우리는 비트토렌트로 파일을 다운로드하려고 하지만 P2P 프로토콜이고 파일을 다운로드할 피어를 찾을 수 없습니다.
이것은 마치 새로운 도시로 이사해서 친구를 사귀는 것과 같습니다. 어쩌면 우리가 동네 술집이나 밋업 그룹에 가는 것처럼요!
중앙 집중식 서버는 피어들이 서로를 알 수 있도록 알려주는 **트래커(tracker)** 의 핵심입니다.
이들은 HTTP[^1] 웹 서버일 뿐이며, 데비안의 서버는 [http://bttracker.debian.org:6969/stat](http://bttracker.debian.org:6969/stat)에서 찾을 수 있습니다.

[^1]: 일부 트래커는 대역폭을 절약하기 위해 [[UDP]](http://bittorrent.org/beps/bep_0015.html) 바이너리 프로토콜을 사용합니다

![trackers](/images/go/bit-torrent/trackers.png)

물론 이러한 중앙 서버는 피어들이 불법 컨텐츠를 교환할 수 있게 둔다면 정부의 단속을 받기 쉽습니다.
여러분은 불법 컨텐츠로 인해 폐쇄된 TorrentSpy, Popcorn Time, 그리고 KickassTorrents 와 같은 트래커에 대해 읽었을 수 있습니다.
오늘날에는 **피어 탐색**도 분산 프로세스로 만들어 중간자를 생략했습니다 (역주: Trackerless Torrent).
우리가 이것까지 구현하지는 않지만 만약 관심이 있다면 **DHT (Distributed Hash Table)**, **PEX (Peer exchange)**, 그리고 **자석 링크 (magnet link)** 같은 몇몇 용어들을 찾아보세요.

## .torrent 파일 파싱 (parsing: 구문 분석)

.torrent 파일에는 토렌트를 통해 다운로드할 수 있는(torrentable) 파일의 내용 및 트래커 연결에 대한 정보가 포함됩니다.
토렌트를 다운로드 하기 위해 필요한 것은 이것뿐입니다. 데비안의 .torrent 파일은 다음과 같습니다.

```
d8:announce41:http://bttracker.debian.org:6969/announce7:comment35:"Debian CD from cdimage.debian.org"13:creation datei1573903810e9:httpseedsl145:https://cdimage.debian.org/cdimage/release/10.2.0//srv/cdbuilder.debian.org/dst/deb-cd/weekly-builds/amd64/iso-cd/debian-10.2.0-amd64-netinst.iso145:https://cdimage.debian.org/cdimage/archive/10.2.0//srv/cdbuilder.debian.org/dst/deb-cd/weekly-builds/amd64/iso-cd/debian-10.2.0-amd64-netinst.isoe4:infod6:lengthi351272960e4:name31:debian-10.2.0-amd64-netinst.iso12:piece lengthi262144e6:pieces26800:�����PS�^�� (binary blob of the hashes of each piece)ee
```

**B인코드(Bencode)** 형식으로 인코딩되어 있고, 우리는 이것을 디코딩해야 합니다.

B인코드는 JSON과 거의 동일한 유형(문자열, 정수, 리스트 및 딕셔너리)의 구조로 인코딩할 수 있습니다.
B인코딩된 데이터는 JSON만큼 사람이 쉽게 읽고 쓸 수 있는 것은 아니지만 바이너리 데이터를 효율적으로
처리할 수 있으며 스트림에서 파싱하는 것이 매우 간단합니다.
문자열은 길이 접두사가 붙으며 `4:spam`와 같이 나타냅니다.
정수는 마커로 시작하고 끝나기 때문에 `7`의 경우 `i7e`로 인코딩됩니다.
리스트와 딕셔너리는 비슷한 방식으로 인코딩됩니다. `l4:spami7ee`는 `['spam', 7]`을, `d4:spami7ee`는 `{spam: 7}`을 나타냅니다.

.torrent 파일을 보기 쉽게 다듬으면 다음과 같습니다.

```c
d
  8:announce
    41:http://bttracker.debian.org:6969/announce
  7:comment
    35:"Debian CD from cdimage.debian.org"
  13:creation date
    i1573903810e
  4:info
    d
      6:length
        i351272960e
      4:name
        31:debian-10.2.0-amd64-netinst.iso
      12:piece length
        i262144e
      6:pieces
        26800:�����PS�^�� (binary blob of the hashes of each piece)
    e
e
```

이 파일에서는 트래커의 URL, 생성 날짜(유닉스 타임스탬프), 파일 이름 및 크기,
다운로드하려는 파일 **조각** 의 SHA-1 해시가 들어 있는 큰 바이너리 블롭을 찾을 수 있습니다.
조각의 정확한 크기는 토렌트마다 다르지만 일반적으로 256KB에서 1MB 사이입니다.
이것은 큰 파일이 수천 개의 조각으로 구성될 수 있다는 것을 의미합니다.
피어들에게서 이 조각들을 다운로드해서 토렌트 파일에 있는 해시와 대조해 보고, 조립해 보고, 파일을 가지게 되는 겁니다!

![pieces](/images/go/bit-torrent/pieces.png)

이 메커니즘을 통해 각 조각의 무결성을 검증할 수 있습니다.
비트토렌트는 이를 통해 우발적인 데이터 손상이나 의도적인 **토렌트 포이즈닝**([torrent poisoning](https://en.wikipedia.org/wiki/Torrent_poisoning)) 을 막을 수 있습니다.
공격자가 역상 공격([preimage attack](https://en.wikipedia.org/wiki/Preimage_attack))을 통해 SHA-1을 해독할 수 없다면, 우리는 요청한 컨텐츠를 정확하게 받을 수 있습니다.

B인코드 파서를 만드는 것은 정말 재미있겠지만, 파싱은 이 글의 목적이 아닙니다.
이해하기 쉬운 Fredrik Lundh의 [50줄짜리 파서](https://effbot.org/zone/bencode.htm)를 찾았지만,
이 프로젝트에서는 [github.com/jackpal/bencode-go](https://github.com/jackpal/bencode-go) 을 사용했습니다.

```go
import (
  "github.com/jackpal/bencode-go"
)

type bencodeInfo struct {
  Pieces      string `bencode:"pieces"`
  PieceLength int    `bencode:"piece length"`
  Length      int    `bencode:"length"`
  Name        string `bencode:"name"`
}

type bencodeTorrent struct {
  Announce string      `bencode:"announce"`
  Info     bencodeInfo `bencode:"info"`
}

// Open 토렌트 파일을 파싱합니다
func Open(r io.Reader) (*bencodeTorrent, error) {
  bto := bencodeTorrent{}
  err := bencode.Unmarshal(r, &bto)
  if err != nil {
    return nil, err
  }
  return &bto, nil
}
```

[github.com/veggiedefender/torrent-client/torrentfile/torrentfile.go](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/torrentfile/torrentfile.go)

저는 구조체를 상대적으로 평평하게 유지하는 것을 좋아하고
애플리케이션 구조체를 직렬화 구조체와 분리하는 것을 좋아하기 때문에
`TorrentFile`이라는 다른 평탄한 구조체를 내보내고
두 구조체 사이에서 변환할 몇 가지 헬퍼 함수를 작성했습니다.

특히 각각의 해시에 쉽게 접근할 수 있도록 `조각`(이전의 문자열)을 해시 조각(각각 `[20]byte`)으로 분할합니다.
또한 (이름, 크기, 조각 해시를 포함한) B인코딩된 `info` 딕셔너리의 SHA-1 해시를 계산했습니다.
이것을 **infohash**라고 하며 트래커 및 피어와 통신할 때 파일 식별자 역할을 합니다.
이에 대해서는 나중에 더 살펴보겠습니다.

![info-hash](/images/go/bit-torrent/info-hash.png)

```go
type TorrentFile struct {
  Announce    string
  InfoHash    [20]byte
  PieceHashes [][20]byte
  PieceLength int
  Length      int
  Name        string
}

func (bto bencodeTorrent) toTorrentFile() (TorrentFile, error) {
  // …
}
```

[github.com/veggiedefender/torrent-client/torrentfile/torrentfile.go#L120-L138](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/torrentfile/torrentfile.go#L120-L138)

## 트래커로부터 피어 찾기

이제 파일과 트래커에 대해 알았으니 트래커와 통신하여 피어로서의 존재를 **알리고** 다른 피어들의 목록을 검색해 보겠습니다.
.torrent 파일에 제공된 'announce' URL에 몇 가지 쿼리 파라미터와 함께 GET 요청을 하면 됩니다.

```go
func (t *TorrentFile) buildTrackerURL(peerID [20]byte, port uint16) (string, error) {
  base, err := url.Parse(t.Announce)
  if err != nil {
    return "", err
  }
  params := url.Values{
    "info_hash":  []string{string(t.InfoHash[:])},
    "peer_id":    []string{string(peerID[:])},
    "port":       []string{strconv.Itoa(int(Port))},
    "uploaded":   []string{"0"},
    "downloaded": []string{"0"},
    "compact":    []string{"1"},
    "left":       []string{strconv.Itoa(t.Length)},
  }
  base.RawQuery = params.Encode()
  return base.String(), nil
}
```

[github.com/veggiedefender/torrent-client/torrentfile/tracker.go#L19-L35](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/torrentfile/tracker.go#L19-L35)

여기서 중요한 것은 다음과 같습니다.

- **info_hash**: 다운로드하려는 파일을 식별합니다. 이것은 우리가 B인코딩된 `info` 딕셔너리에서 계산한 infohash입니다. 트래커는 이를 사용하여 어떤 피어를 보여줄지 결정합니다.
- **peer_id**: 트래커와 피어들에게 `우리`를 식별시키기 위한 20바이트 이름입니다. 이를 위해 20개의 랜덤 바이트를 생성합니다. 실제 비트토렌트 클라이언트는 클라이언트 소프트웨어와 버전을 식별하는 `-TR2940-k8hj0wgej6ch`와 같은 ID를 가지고 있습니다. 여기서 TR2940은 전송 클라이언트 2.94를 의미합니다. [(Peer ID Conventions)](https://www.bittorrent.org/beps/bep_0020.html)

![info-hash-peer-id](/images/go/bit-torrent/info-hash-peer-id.png)

## 트래커 응답 분석

다음과 같이 B인코딩된 응답을 받았습니다.

```c
d
  8:interval
    i900e
  5:peers
    252:(another long binary blob)
e
```

`Interval`은 얼마나 자주 트래커에 다시 연결하여 피어 목록을 새로 고쳐야 하는지 알려줍니다.
900이라는 값은 15분(900초)마다 다시 연결해야 함을 의미합니다.

`Peers`는 각 피어의 IP 주소를 포함하는 또 다른 긴 바이너리 블롭입니다.
`6바이트의 그룹들`로 이루어져 있습니다.
각 그룹의 처음 4바이트는 피어의 IP 주소를 나타냅니다. 각 1 바이트는 IP 숫자를 나타냅니다.
마지막 2바이트는 포트 번호를 빅-엔디안 `uint16`으로 나타냅니다.
**빅-엔디안** 또는 **네트워크 바이트 순서**[^2]는 바이트 그룹을 왼쪽부터 담아 정수로 해석하는 것을 말합니다.
예를 들어 `0x1A`, `0xE1` 바이트는 `0x1AE1` 또는 십진수로 6881을 만듭니다.[^3]

[^2]: 역주: network byte order -> big-endian / host byte order -> little-endian
[^3]: 동일한 바이트를 **little-endian** 순서로 해석하면 0xE11A = 57626이 됩니다.

![address](/images/go/bit-torrent/address.png)

```go
// Peer 피어의 연결 정보를 인코딩합니다
type Peer struct {
  IP   net.IP
  Port uint16
}

// Unmarshal 버퍼에서 피어의 IP 주소와 포트 번호를 파싱합니다
func Unmarshal(peersBin []byte) ([]Peer, error) {
  const peerSize = 6 // 4 for IP, 2 for port
  numPeers := len(peersBin) / peerSize
  if len(peersBin)%peerSize != 0 {
    err := fmt.Errorf("Received malformed peers")
    return nil, err
  }
  peers := make([]Peer, numPeers)
  for i := 0; i < numPeers; i++ {
    offset := i * peerSize
    peers[i].IP = net.IP(peersBin[offset : offset+4])
    peers[i].Port = binary.BigEndian.Uint16(peersBin[offset+4 : offset+6])
  }
  return peers, nil
}
```

[github.com/veggiedefender/torrent-client/peers/peers.go](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/peers/peers.go)

# 피어로부터 다운로드하기

이제 피어 목록이 있습니다.
피어와 연결하여 조각을 다운로드할 시간입니다!
우리는 이 과정을 몇 단계로 나눌 수 있습니다.
각 피어에 대해 다음을 수행하고자 합니다.

1. 피어와 TCP 연결을 시작합니다. 이것은 전화를 거는 것과 같습니다.
2. 양방향 비트토렌트 **핸드셰이크**를 완료합니다.. *"안녕?" "안녕."*
3. **조각**을 다운로드 하기 위해 **메시지**를 교환합니다. *"231번 조각 주세요."*

## TCP 연결

```go
conn, err := net.DialTimeout("tcp", peer.String(), 3*time.Second)
if err != nil {
  return nil, err
}
```

[github.com/veggiedefender/torrent-client/client/client.go#L65-L69](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/client/client.go#L65-L69)

연결할 수 없는 피어에 너무 많은 시간을 낭비하지 않도록 시간 제한을 설정했습니다.
대부분의 경우 표준 TCP 연결입니다.

## 핸드셰이크 완료

피어와의 연결을 설정했지만 다음과 같은 가정을 검증하기 위해 핸드셰이크를 수행하려고 합니다.

- 피어는 비트토렌트 프로토콜을 사용하여 통신할 수 있습니다.
- 피어는 우리의 메시지를 이해하고 응답할 수 있습니다.
- 피어는 우리가 원하는 파일을 가지고 있거나 적어도 우리가 무엇을 말하고 있는지 알고 있습니다.

![handshake](/images/go/bit-torrent/handshake.png)

아버지는 제게 악수(handshake)를 잘 하는 비결은 손을 단단히 잡고 눈을 마주치는 것이라고 말씀하셨습니다.
좋은 비트토렌트 핸드셰이크의 비결은 다음과 같이 다섯 부분으로 구성됩니다.

1. 항상 19로 지정된 프로토콜 식별자의 길이. (16진수로는 0x13)
2. **pstr**이라 불리는 프로토콜 식별자는 항상 `BitTorrent protocol`.
3. 모두 0으로 지정된 **8개의 예약된 바이트**. 그 중 일부를 1로 뒤집어서 특정 [확장 기능](http://www.bittorrent.org/beps/bep_0010.html)을 지원한다는 것을 나타냅니다. 하지만 지금은 그렇지 않으니 0으로 유지하겠습니다.
4. 우리가 원하는 파일을 식별할 앞서 계산한 **infohash**.
5. 우리 스스로를 식별하기 위해 만든 **Peer ID**.

합치면 핸드셰이크 문자열은 다음과 같이 보일 수 있습니다.

```
\x13BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00\x86\xd4\xc8\x00\x24\xa4\x69\xbe\x4c\x50\xbc\x5a\x10\x2c\xf7\x17\x80\x31\x00\x74-TR2940-k8hj0wgej6ch
```

피어에게 핸드셰이크를 보낸 후 동일한 형식으로 핸드셰이크를 다시 받아야 합니다.
받은 infohash는 보낸 정보와 일치해야 동일한 파일에 대해 말하고 있다는 것을 알 수 있습니다.
모든 일이 계획대로 진행되면 다음 단계로 넘어갑니다.
그렇지 않다면 뭔가 잘못되었기 때문에 연결을 끊을 수 있습니다.
*"안녕?" "这是谁？ 你想要什么？" "알았어요, 와...잘못 걸었어요.."*

코드에서 핸드셰이크를 나타내는 구조체를 만들고, 이것을 직렬화하고 읽는 몇 가지 메소드를 작성하겠습니다.

```go
// Handshake 피어가 자신을 식별하는 데 사용하는 특별한 메시지입니다.
type Handshake struct {
  Pstr     string
  InfoHash [20]byte
  PeerID   [20]byte
}

// Serialize 핸드셰이크를 버퍼에 직렬화합니다.
func (h *Handshake) Serialize() []byte {
  buf := make([]byte, len(h.Pstr)+49)
  buf[0] = byte(len(h.Pstr))
  curr := 1
  curr += copy(buf[curr:], h.Pstr)
  curr += copy(buf[curr:], make([]byte, 8)) // 8 reserved bytes
  curr += copy(buf[curr:], h.InfoHash[:])
  curr += copy(buf[curr:], h.PeerID[:])
  return buf
}

// Read 스트림에서 핸드셰이크를 파싱합니다.
func Read(r io.Reader) (*Handshake, error) {
  // 역직렬화 수행
  // ...
}
```

[github.com/veggiedefender/torrent-client/handshake/handshake.go](https://github.com/veggiedefender/torrent-client/blob/a83013d250dd9b4268cceace28e4cd82b07f2cbd/handshake/handshake.go)

## 메시지 주고 받기

첫 핸드셰이크를 마치면 `메시지`를 주고받을 수 있습니다.
하지만 나머지 피어들이 메시지를 받아들일 준비가 안 되어 있다면,
모두가 준비가 되었다고 말하기 전에는 보낼 수 없습니다.
이 상태에서는 나머지 피어들에게 `chocked`를 당합니다.
그들은 우리가 데이터를 요청해도 된다는 것을 알리기 위해 `unchoke` 메시지를 보낼 것입니다.
기본적으로 우리는 입증될 때까지 막힌다고 가정합니다.

unchoke 메시지를 받으면 우리는 조각에 대한 `요청`을 보낼 수 있고,
피어들은 조각이 담긴 메시지를 우리에게 보낼 수 있습니다.

![choke](/images/go/bit-torrent/choke.png)

### 메시지 해석

메시지는 길이, `ID`, `페이로드(payload)`를 가집니다. 이것은 다음과 같습니다.

![message](/images/go/bit-torrent/message.png)

메시지는 메시지의 바이트 길이를 알려주는 길이 표시로 시작합니다.
32비트 정수이므로 빅-엔디안 순서의 4바이트로 압축할 수 있습니다.
다음 바이트인 **ID**는 어떤 유형의 메시지를 수신하는지 알려줍니다.
예를 들어 `2`바이트는 "관심있음(interested)"을 의미합니다.
마지막으로 선택값인 **페이로드(payload)** 는 메시지의 남은 길이를 채웁니다.

```go
type messageID uint8

const (
  MsgChoke         messageID = 0
  MsgUnchoke       messageID = 1
  MsgInterested    messageID = 2
  MsgNotInterested messageID = 3
  MsgHave          messageID = 4
  MsgBitfield      messageID = 5
  MsgRequest       messageID = 6
  MsgPiece         messageID = 7
  MsgCancel        messageID = 8
)

// Message 메시지의 ID 및 페이로드를 저장합니다.
type Message struct {
  ID      messageID
  Payload []byte
}

// Serialize 메시지를 다음과 같은 형식으로 버퍼에 직렬화합니다.
// <길이 접두사><메시지 ID><페이로드>
// `nil`은 keep-live 메시지로 해석합니다.
func (m *Message) Serialize() []byte {
  if m == nil {
    return make([]byte, 4)
  }
  length := uint32(len(m.Payload) + 1) // +1 for id
  buf := make([]byte, 4+length)
  binary.BigEndian.PutUint32(buf[0:4], length)
  buf[4] = byte(m.ID)
  copy(buf[5:], m.Payload)
  return buf
}
```

[github.com/veggiedefender/torrent-client/message/message.go#L90-L103](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/message/message.go#L90-L103)

스트림에서 메시지를 읽으려면 해당 메시지 형식을 따릅니다.
우리는 4바이트를 읽고 메시지의 **길이**를 얻기 위해 `uint32`로 해석합니다.
그런 다음 **ID**(처음 1바이트) 및 **payload**(나머지 바이트)를 얻습니다.

```go
// Read 스트림에서 메시지를 파싱합니다. keep-alive 메시지는 `nil`을 반환합니다.
func Read(r io.Reader) (*Message, error) {
  lengthBuf := make([]byte, 4)
  _, err := io.ReadFull(r, lengthBuf)
  if err != nil {
    return nil, err
  }
  length := binary.BigEndian.Uint32(lengthBuf)

  // keep-alive 메시지
  if length == 0 {
    return nil, nil
  }

  messageBuf := make([]byte, length)
  _, err = io.ReadFull(r, messageBuf)
  if err != nil {
    return nil, err
  }

  m := Message{
    ID:      messageID(messageBuf[0]),
    Payload: messageBuf[1:],
  }

  return &m, nil
}
```

[github.com/veggiedefender/torrent-client/message/message.go#L105-L131](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/message/message.go#L105-L131)

### 비트 필드 (Bitfields)

가장 흥미로운 유형의 메시지 중 하나는 **비트 필드(bitfield)** 입니다.
이 자료 구조는 피어들이 우리에게 보낼 수 있는 조각을 효율적으로 인코딩하는 데 사용됩니다.
비트필드는 바이트 배열처럼 생겼고, 어떤 조각을 가지고 있는지 확인하기 위해서는 단지 1로 설정된 *비트*의 위치를 보면 됩니다.
이것을 커피숍 쿠폰에 비유할 수 있습니다.
비트가 전부 `0`인 카드부터 시작해서 하나씩 `1`로 바꿔서 "도장" 찍듯이 표시합니다.

![bitfield](/images/go/bit-torrent/bitfield.png)

*바이트* 대신 *비트*로 작업해서 비트필드 자료 구조는 크기가 매우 작습니다.
한 바이트의 공간에 8개의 조각 정보(`bool` 크기)를 채워 넣을 수 있습니다.
단점은 값에 접근하는 것이 좀 더 까다로워진다는 것입니다.
컴퓨터가 처리할 수 있는 가장 작은 메모리 단위는 바이트입니다.
따라서 비트에 접근하려면 몇 가지 비트 조작(bitwise manipulation)을 수행해야 합니다.

```go
// Bitfield 피어가 가지고 있는 조각들을 나타냅니다
type Bitfield []byte

// HasPiece 특정 인덱스를 가진 비트 필드가 설정되어 있는지 알려줍니다
func (bf Bitfield) HasPiece(index int) bool {
  byteIndex := index / 8
  offset := index % 8
  return bf[byteIndex]>>(7-offset)&1 != 0
}

// SetPiece 비트 필드에 비트를 설정합니다
func (bf Bitfield) SetPiece(index int) {
  byteIndex := index / 8
  offset := index % 8
  bf[byteIndex] |= 1 << (7 - offset)
}
```

[github.com/veggiedefender/torrent-client/bitfield/bitfield.go](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/bitfield/bitfield.go)

## 모두 합치기

이제 토렌트를 다운로드하는 데 필요한 모든 도구를 확보했습니다.
트래커에서 얻은 피어 목록이 있으며, TCP로 연결하고 핸드셰이크를 하며,
메시지를 주고받음으로써 피어들과 통신할 수 있습니다.
마지막 큰 문제는 여러 피어와 동시에 통신하는 **동시성(concurrency)** 을 처리하고
상호 작용하는 피어들의 **상태**를 관리하는 것입니다.
둘 다 고전적으로 어려운 문제입니다.

### 동시성 관리: 채널(channel)을 큐(queue)로

Go에서는 [통신을 통해 메모리를 공유](https://blog.golang.org/share-memory-by-communicating)하며
Go 채널을 비용이 적은 스레드-세이프 큐라고 생각할 수 있습니다.

두 채널을 설정하여 동시적인 작업자들(concurrent workers)을 동기화합니다.
하나는 피어 간에 작업(다운로드할 조각)을 분배하기 위한 채널이고,
다른 하나는 다운로드한 조각들을 모으기 위한 채널입니다.
다운로드된 조각들이 결과 채널을 통해 들어올 때,
우리는 그것들을 버퍼에 복사해서 완전한 파일로 조립할 수 있습니다.

```go
// 작업자가 작업을 찾고 결과를 보낼 수 있도록 큐를 초기화합니다
workQueue := make(chan *pieceWork, len(t.PieceHashes))
results := make(chan *pieceResult)
for index, hash := range t.PieceHashes {
  length := t.calculatePieceSize(index)
  workQueue <- &pieceWork{index, hash, length}
}

// 작업을 시작합니다
for _, peer := range t.Peers {
  go t.startDownloadWorker(peer, workQueue, results)
}

// 결과가 가득 찰 때까지 버퍼로 결과를 수집합니다
buf := make([]byte, t.Length)
donePieces := 0
for donePieces < len(t.PieceHashes) {
  res := <-results
  begin, end := t.calculateBoundsForPiece(res.index)
  copy(buf[begin:end], res.buf)
  donePieces++
}
close(workQueue)
```

[github.com/veggiedefender/torrent-client/p2p/p2p.go#L188-L214](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/p2p/p2p.go#L188-L214)

트래커에서 받은 피어마다 작업자 고루틴을 생성합니다.
피어와 연결하고 핸드셰이크한 다음 `workQueue`에서 작업을 검색하여 다운로드를 시도하고,
`results` 채널을 통해 다운로드한 조각들을 다시 보냅니다.

![download](/images/go/bit-torrent/download.png)

```go
func (t *Torrent) startDownloadWorker(peer peers.Peer, workQueue chan *pieceWork, results chan *pieceResult) {
  c, err := client.New(peer, t.PeerID, t.InfoHash)
  if err != nil {
    log.Printf("Could not handshake with %s. Disconnecting\n", peer.IP)
    return
  }
  defer c.Conn.Close()
  log.Printf("Completed handshake with %s\n", peer.IP)

  c.SendUnchoke()
  c.SendInterested()

  for pw := range workQueue {
    if !c.Bitfield.HasPiece(pw.index) {
      workQueue <- pw // 큐에 조각을 다시 넣습니다
      continue
    }

    // 조각 다운로드
    buf, err := attemptDownloadPiece(c, pw)
    if err != nil {
      log.Println("Exiting", err)
      workQueue <- pw // 큐에 조각을 다시 넣습니다
      return
    }

    err = checkIntegrity(pw, buf)
    if err != nil {
      log.Printf("Piece #%d failed integrity check\n", pw.index)
      workQueue <- pw // 큐에 조각을 다시 넣습니다
      continue
    }

    c.SendHave(pw.index)
    results <- &pieceResult{pw.index, buf}
  }
}
```

[github.com/veggiedefender/torrent-client/p2p/p2p.go#L133-L169](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/p2p/p2p.go#L133-L169)

### 상태 관리

구조체에 있는 각 피어들을 추적하고 메시지를 읽을 때 해당 구조체의 필드값을 수정합니다.
피어에서 다운로드한 용량, 요청한 용량, 중단(choked) 여부 등의 데이터가 포함됩니다.
만약 더 확장하기를 원한다면 이것을 유한 상태 기계(FSM)로 형식화할 수 있습니다.
하지만 지금은 구조체와 스위치만으로 충분합니다.

```go
type pieceProgress struct {
  index      int
  client     *client.Client
  buf        []byte
  downloaded int
  requested  int
  backlog    int
}

func (state *pieceProgress) readMessage() error {
  msg, err := state.client.Read() // this call blocks
  switch msg.ID {
  case message.MsgUnchoke:
    state.client.Choked = false
  case message.MsgChoke:
    state.client.Choked = true
  case message.MsgHave:
    index, err := message.ParseHave(msg)
    state.client.Bitfield.SetPiece(index)
  case message.MsgPiece:
    n, err := message.ParsePiece(state.index, state.buf, msg)
    state.downloaded += n
    state.backlog--
  }
  return nil
}
```

[github.com/veggiedefender/torrent-client/p2p/p2p.go#L53-L83](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/p2p/p2p.go#L53-L83)

### 요청을 보낼 시간입니다!

파일, 조각 및 조각 해시는 전부가 아닙니다. 조각을 **블록**으로 세분하여 더 발전시킬 수 있습니다.
블록은 조각의 일부입니다. 해당 블록이 속한 조각의 **인덱스**,
조각에서 블록의 바이트 **오프셋** 및 블록의 **길이**를 통해 블록을 정의할 수 있습니다.
피어에서 데이터를 요청하면 실제로 블록을 요청합니다.
블록의 크기는 일반적으로 16KB이므로 256KB 조각 하나에 실제로 16개의 요청이 필요할 수 있습니다.

피어가 16KB보다 큰 블록에 대한 요청을 수신하는 경우 연결을 끊어야 합니다.
제 경험상 요청을 128KB까지 처리하는 경우가 많았습니다.
하지만 규격보다 큰 크기의 블록을 요청할 때 전체 속도가 크게 향상되지는 않았으므로
규격을 준수하는 것이 더 나을 수 있습니다.

### 파이프라이닝

네트워크 왕복 비용은 많이 들고, 각 블록을 하나씩 요청하면 다운로드 성능이 상당히 저하됩니다.
따라서 처리되지 않은 일부 요청들을 지속적으로 모으기 위해 **파이프라인(pipeline)으로** 연결하는 것이 중요합니다.
이렇게 하면 연결 처리량을 상당히 증가시킬 수 있습니다.

![pipelining](/images/go/bit-torrent/pipelining.png)

일반적으로 비트토렌트 클라이언트는 5개의 파이프라인 요청 큐를 유지했으며, 이것이 제가 사용할 값입니다.
파이프라인을 늘리면 다운로드 속도가 최대 두 배까지 빨라진다는 것을 알았습니다.

최신 클라이언트는 [적응형(adaptive)](https://luminarys.com/posts/writing-a-bittorrent-client.html) 큐 크기를
사용하여 최신 네트워크 속도와 조건을 더 잘 수용합니다.
이는 분명히 조정할 만한 가치가 있는 매개 변수이며, 향후 성능 최적화를 위한 쉬운 방법(low-hanging fruit)입니다.

```go
// MaxBlockSize 요청할 수 있는 최대 바이트 수
const MaxBlockSize = 16384

// MaxBacklog 클라이언트가 파이프라인에서 수행할 수 없는 요청 수입니다.
const MaxBacklog = 5

func attemptDownloadPiece(c *client.Client, pw *pieceWork) ([]byte, error) {
  state := pieceProgress{
    index:  pw.index,
    client: c,
    buf:    make([]byte, pw.length),
  }

  // 데드라인을 설정하면 응답하지 않는 피어를 떼어내는 데 도움이 됩니다
  // 262KB 조각을 다운로드하려면 30초가 충분합니다
  c.Conn.SetDeadline(time.Now().Add(30 * time.Second))
  defer c.Conn.SetDeadline(time.Time{}) // 데드라인 비활성화

  for state.downloaded < pw.length {
    // unchocked일 경우 완료되지 않은 요청이 충분히 쌓일 때까지 요청을 보냅니다.
    if !state.client.Choked {
      for state.backlog < MaxBacklog && state.requested < pw.length {
        blockSize := MaxBlockSize
        // 마지막 블록은 일반 블록보다 짧을 수 있습니다.
        if pw.length-state.requested < blockSize {
          blockSize = pw.length - state.requested
        }

        err := c.SendRequest(pw.index, state.requested, blockSize)
        if err != nil {
          return nil, err
        }
        state.backlog++
        state.requested += blockSize
      }
    }

    err := state.readMessage()
    if err != nil {
      return nil, err
    }
  }

  return state.buf, nil
}
```

[github.com/veggiedefender/torrent-client/p2p/p2p.go#L85-L123](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/p2p/p2p.go#L85-L123)


### main.go

아주 간단합니다. 거의 다 왔어요.

```go
package main

import (
    "log"
    "os"

    "github.com/veggiedefender/torrent-client/torrentfile"
)

func main() {
  inPath := os.Args[1]
  outPath := os.Args[2]

  tf, err := torrentfile.Open(inPath)
  if err != nil {
      log.Fatal(err)
  }

  err = tf.DownloadToFile(outPath)
  if err != nil {
      log.Fatal(err)
  }
}
```

[github.com/veggiedefender/torrent-client/main.go](https://github.com/veggiedefender/torrent-client/blob/2bde944888e1195e81cc5d5b686f6ec3a9f08c25/main.go)

[데모 영상](https://asciinema.org/a/xqRSB0Jec8RN91Zt89rbb9PcL)

# 이것이 전부가 아닙니다

간결함을 위해 몇 가지 중요한 부분 코드만 포함시켰습니다.
특히 글루 코드, 파싱, 유닛 테스트, 글자를 만드는 지루한 부분은 생략했습니다.
관심 있으시다면 [전체 소스 코드](https://github.com/veggiedefender/torrent-client)를 확인하세요.

---

> 역자: 간단히 테스트 해보려면 아래의 명령어를 실행하세요.

```shell
# Go는 설치되어 있다고 가정합니다.
git clone https://github.com/veggiedefender/torrent-client.git
cd torrent-client
# linux, darwin
curl -L http://bttracker.debian.org:6969/file/debian-10.0.0-amd64-netinst.iso.torrent?info_hash=7f9161c88883c639bcde80d7f0a6045ab9cf16bb -o debian.torrent
# windows
wget http://bttracker.debian.org:6969/file/debian-10.0.0-amd64-netinst.iso.torrent?info_hash=7f9161c88883c639bcde80d7f0a6045ab9cf16bb -o debian.torrent
go run main.go debian.torrent debian.iso
```
