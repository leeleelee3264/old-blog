---
layout: post
title: "[Security] Apply Digital Certificate"
date: 2022-08-27 08:43:59
author: Jamie Lee
categories: Infra
tags:	SSL
pagination:
enabled: true
---


**Index**

1.  CA
2.  CA에서 인증서 생성하기
3.  인증서 적용하기
4.  (plus) 인증서가 사용되는 프로세스 모식도


* * *

CA
==

공개키와 비밀키만을 이용해 암호화는 수행하면 보안에 매우 취약해진다.

아래의 그림처럼 해커가 사용자 B에게 해커의 공개키를 사용하여 데이터를 보낼 경우 사용자 B는 사용자 A가 보낸 데이터라착각할 수 있다. 이와 같은 해커의 공격 방식을 MTM(Man in the Middle Attack)이라고 한다. 이와 같은 취약점을 해결하기 위해 CA(Certificate Authority) 라는 인증 노드를 사용하게 된다.
<br>

![](/assets/img/post/certificate/attachments/4565565736/4669931563.png)
<br>

CA는 신뢰할 수 있는 기관에 의해 운영되는데, 주요 업무는 공개키 등록 시 본인 인증과 X.509와 같은 디지털 인증서 생성 및 발생 등이 있다. CA가 사용되는 시나리오는 아래와 같다.

1.  사용자 A가 자신의 공개키를 CA에 등록한다. (본인 인증을 거친다)
2.  그 후 사용자 B가 사용자 A의 공개키가 필요할 경우 CA에 가서 사용자 A의 공개키를 요청한다.
3.  CA는 암호화 하여 사용자 A의 공개키를 사용자 B에게 전달한다.
4.  공개키를 건내는 과정에서 CA외에 공개키를 전달할 수 있는 곳이 없기 때문에 사용자 B는 해당 공개키만을 사용자 A의 공개키라고 믿으면 된다.

<br>

![](/assets/img/post/certificate/attachments/4565565736/4669997094.png)

<br>

유명한 CA들은 아래와 같다. CA의 인증서를 대리 구매해주는 서비스들이 외국에도, 한국에도 있지만 직접 CA에 가서 사는 것이 더 좋다. CA에 직접 가서 구매했을 때 QnA나 대응도 더 빠르고, 자세하며 나중에 인증서를 관리할 때에도 더 편했다.

![](/assets/img/post/certificate/attachments/4565565736/4666163323.png)

<br>
<br>

CA에서 인증서 생성하기
=============

SAN
---

1.  Optional 이고, 선택한 인증서의 가격에 따라서 보장하는 SAN의 개수에도 차이가 있다.
2.  Subject Alternative Name 의 약자이다.
3.  하나의 인증서로 여러개의 FQDN (Fully Qualified Domain Name)를 보장할 수 있다.
4.  하나의 IP로 향햐는 도메인이 여러개가 있을 때 자주 사용이 된다.

<br>

#### SAN의 형태

```java
www.digicert.com 
knowledge.digicert.com 
www.thawte.com
```
<br>

CSR 생성하기
--------

#### CSR 이란?

1. Certificate signing request로, 어플리케이션에서 CA로부터 digital identify certificate을 발급받기 위해 보내는 메세지이다. 가장 많이 사용되는 포맷은 PKCS #10이다.
2. CSR 을 만들기 전에 PrivateKey를 만드는데, 이 PrivateKey가 바로 PKI에서 사용되는 그 **PrivateKey로 아무한테도 노출하면 안된다.**
3. [https://my.gogetssl.com/en](https://my.gogetssl.com/en) 처럼 인증서 중간 유통 업체들이 때때로 CSR과 PrivateKey를 만들어서 사용자에게 주기도 한다.
   1. 중간 유통 업체를 이용할 때에는 인증서를 발급한 CA에서 직접 지원을 받을 때 문제가 생길 수 있다. 
   2. 그리고 보안상 PrivateKey가 노출이 된 것이니 허점이 있을 수 있다.

<br>


#### OpenSSL로 CSR 생성하기

```java
openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout server.key -out server.csr
```

→ Private key을 생성한다.  
→ 생성한 Private key를 사용하여 CSR을 생성한다.  
→ CSR을 생성할 때 아래의 값들에 대한 정보를 입력해야 한다.

![](/assets/img/post/certificate/attachments/4565565736/4632412194.png)

<br>

#### Common Name

> SAN이 나오고 나서부터 Common Name은 실제적인 효력 보다는 과거의 레거시 형태로 남아있다. 이번에도 CSR을 작성할 때 OV를 만들어야 하기 때문에 Common Name에 도메인을 쓰지 않고 회사 이름을 넣었다.

<br>

인증서가 설치되는 서버의 이름과 정확하게 매치해야 한다. 만약 서브 도메인을 위해 인증서를 발급했을 경우에는 full 서브도메인을 정확하게 명시해줘야한다.

example:

```java
도메인: mydomain.com 
서브 도메인: www 
common name: www.domain.com
```

<br>

#### Common Name vs SAN

CSR을 생성할 때 SSL Certificate이 적용되는 도메인을 Common Name에 적어야 한다. 그럼 CSR을 생성할 때 작성하는 Common Name과 CA에 인증서를 신청할 때 작성하는 SAN에는 어떤 차이가 있을까?

1.  common name은 단 하나의 엔트리만 입력을 할 수 있다. (wildcard 또는 non-wildcard 이라도 단 하나만 입력을 할수 있다는 것은 변함이 없다)
2.  SAN은 common name의 이런 제약을 없애기 위해 생겨났다. SAN이 있기 때문에 multi-name SSL 인증서를 만들 수 있게 되었다.
3.  SAN에는 여러가지 값을 넣을 수 있고, common name에 넣었던 값도 동일하게 넣을 수 있다.
4.  **SAN이 서버 네임이 일치하는 가 확인하기 위한 유일한 필수 레퍼런스가 되었다.**


<br>

인증서 관련 커맨드
----------

### 웹사이트에서 사용하고 있는 인증서 가져오기:

```java
echo | openssl s_client -servername google.com -connect google.com:443 |\\n  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certificate.crt
```

<br>

### 인증서 열어보기

간단하게 인증서 조회를 하기 위해서는 online parser를 사용할 수 있다. [[Online Parser]](https://certlogik.com/decoder/)
파싱의 결과로 나온 field에 대한 설명은 [[LeeLee- Digital Certificate]](https://https://https://leeleelee3264.github.io/leeleelee3264.github.io-old/infra/2022/06/15/digital-certificate-part-one.html) 에서 더 자세하게 확인할 수 있다.

```java
openssl x509 -in certificate.crt -noout -text 
```


![](/assets/img/post/certificate/images/icons/grey_arrow_down.png)

<br> 

파싱 결과 예시:

```java
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            59:43:1c:7c:0e:b1:5c:49:0a:01:4e:60:34:b8:2c:b2
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, O=Google Trust Services LLC, CN=GTS CA 1C3
        Validity
            Not Before: Apr 25 08:31:18 2022 GMT
            Not After : Jul 18 08:31:17 2022 GMT
        Subject: CN=*.google.com
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:81:63:ab:d3:29:a2:15:6c:ee:b7:43:66:55:c5:
                    88:6e:70:9b:4d:43:40:66:ea:a4:fc:c0:06:8b:4c:
                    fd:60:23:5f:f7:a0:e4:3c:5a:af:7f:e5:36:63:88:
                    55:dd:e2:60:41:6c:a1:27:3d:48:fb:2e:6a:21:6d:
                    01:aa:2e:25:7e
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                8B:09:31:88:DD:30:A6:59:D3:86:E5:3D:EA:06:6D:F3:C0:25:96:D5
            X509v3 Authority Key Identifier:
                keyid:8A:74:7F:AF:85:CD:EE:95:CD:3D:9C:D0:E2:46:14:F3:71:35:1D:27

            Authority Information Access:
                OCSP - URI:http://ocsp.pki.goog/gts1c3
                CA Issuers - URI:http://pki.goog/repo/certs/gts1c3.der

            X509v3 Subject Alternative Name:
                DNS:*.google.com, DNS:*.appengine.google.com, DNS:*.bdn.dev, DNS:*.cloud.google.com, DNS:*.crowdsource.google.com, DNS:*.datacompute.google.com, DNS:*.google.ca, DNS:*.google.cl, DNS:*.google.co.in, DNS:*.google.co.jp, DNS:*.google.co.uk, DNS:*.google.com.ar, DNS:*.google.com.au, DNS:*.google.com.br, DNS:*.google.com.co, DNS:*.google.com.mx, DNS:*.google.com.tr, DNS:*.google.com.vn, DNS:*.google.de, DNS:*.google.es, DNS:*.google.fr, DNS:*.google.hu, DNS:*.google.it, DNS:*.google.nl, DNS:*.google.pl, DNS:*.google.pt, DNS:*.googleadapis.com, DNS:*.googleapis.cn, DNS:*.googlevideo.com, DNS:*.gstatic.cn, DNS:*.gstatic-cn.com, DNS:googlecnapps.cn, DNS:*.googlecnapps.cn, DNS:googleapps-cn.com, DNS:*.googleapps-cn.com, DNS:gkecnapps.cn, DNS:*.gkecnapps.cn, DNS:googledownloads.cn, DNS:*.googledownloads.cn, DNS:recaptcha.net.cn, DNS:*.recaptcha.net.cn, DNS:recaptcha-cn.net, DNS:*.recaptcha-cn.net, DNS:widevine.cn, DNS:*.widevine.cn, DNS:ampproject.org.cn, DNS:*.ampproject.org.cn, DNS:ampproject.net.cn, DNS:*.ampproject.net.cn, DNS:google-analytics-cn.com, DNS:*.google-analytics-cn.com, DNS:googleadservices-cn.com, DNS:*.googleadservices-cn.com, DNS:googlevads-cn.com, DNS:*.googlevads-cn.com, DNS:googleapis-cn.com, DNS:*.googleapis-cn.com, DNS:googleoptimize-cn.com, DNS:*.googleoptimize-cn.com, DNS:doubleclick-cn.net, DNS:*.doubleclick-cn.net, DNS:*.fls.doubleclick-cn.net, DNS:*.g.doubleclick-cn.net, DNS:doubleclick.cn, DNS:*.doubleclick.cn, DNS:*.fls.doubleclick.cn, DNS:*.g.doubleclick.cn, DNS:dartsearch-cn.net, DNS:*.dartsearch-cn.net, DNS:googletraveladservices-cn.com, DNS:*.googletraveladservices-cn.com, DNS:googletagservices-cn.com, DNS:*.googletagservices-cn.com, DNS:googletagmanager-cn.com, DNS:*.googletagmanager-cn.com, DNS:googlesyndication-cn.com, DNS:*.googlesyndication-cn.com, DNS:*.safeframe.googlesyndication-cn.com, DNS:app-measurement-cn.com, DNS:*.app-measurement-cn.com, DNS:gvt1-cn.com, DNS:*.gvt1-cn.com, DNS:gvt2-cn.com, DNS:*.gvt2-cn.com, DNS:2mdn-cn.net, DNS:*.2mdn-cn.net, DNS:googleflights-cn.net, DNS:*.googleflights-cn.net, DNS:admob-cn.com, DNS:*.admob-cn.com, DNS:*.gstatic.com, DNS:*.metric.gstatic.com, DNS:*.gvt1.com, DNS:*.gcpcdn.gvt1.com, DNS:*.gvt2.com, DNS:*.gcp.gvt2.com, DNS:*.url.google.com, DNS:*.youtube-nocookie.com, DNS:*.ytimg.com, DNS:android.com, DNS:*.android.com, DNS:*.flash.android.com, DNS:g.cn, DNS:*.g.cn, DNS:g.co, DNS:*.g.co, DNS:goo.gl, DNS:www.goo.gl, DNS:google-analytics.com, DNS:*.google-analytics.com, DNS:google.com, DNS:googlecommerce.com, DNS:*.googlecommerce.com, DNS:ggpht.cn, DNS:*.ggpht.cn, DNS:urchin.com, DNS:*.urchin.com, DNS:youtu.be, DNS:youtube.com, DNS:*.youtube.com, DNS:youtubeeducation.com, DNS:*.youtubeeducation.com, DNS:youtubekids.com, DNS:*.youtubekids.com, DNS:yt.be, DNS:*.yt.be, DNS:android.clients.google.com, DNS:developer.android.google.cn, DNS:developers.android.google.cn, DNS:source.android.google.cn
            X509v3 Certificate Policies:
                Policy: 2.23.140.1.2.1
                Policy: 1.3.6.1.4.1.11129.2.5.3

            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://crls.pki.goog/gts1c3/QOvJ0N1sT2A.crl

            1.3.6.1.4.1.11129.2.4.2:
                ......v.)y...99!.Vs.c.w..W}.`
..M]&\%]......`........G0E.!......Y.Z...Z.s#...Al...&......Wi. m.-a..._^,...#....D.tZ.j..W.g....w...^.h.O.l..._N>Z.....j^.;.. D\*s....`..!.....H0F.!..6:.?...f..m.}%.r..........E.....!..U....G...%.$D.mG.B..
    Signature Algorithm: sha256WithRSAEncryption
         5c:2b:62:ec:f6:ee:92:0c:28:98:92:af:35:f0:78:5b:75:f2:
         a2:c5:e9:56:04:da:31:ed:0c:92:16:3a:14:47:f9:60:7d:e4:
         36:33:82:13:68:54:37:47:81:f8:b6:0e:66:a7:87:c4:f5:82:
         ca:58:62:a2:15:63:16:28:5b:8e:bc:e7:18:af:97:a2:f4:92:
         92:e3:2f:69:df:ba:7a:80:92:20:14:22:4f:3d:26:69:c6:f8:
         90:d1:2c:36:57:0a:5c:20:00:86:d2:bd:52:db:19:39:46:12:
         b0:65:1d:16:3d:f1:58:4b:d6:19:c0:4b:0d:eb:ad:0b:b9:1c:
         03:ad:cb:d1:04:33:a2:2c:b8:33:f6:01:7c:71:7f:e8:8a:32:
         c1:74:9a:11:f7:ab:b9:ff:f8:89:99:f3:f9:50:7b:31:c7:fa:
         fc:71:d1:c6:f2:b4:d2:82:93:84:ae:d8:eb:55:41:d4:de:9d:
         7f:47:44:05:4a:fb:a7:09:b2:89:99:a7:7f:64:13:52:be:73:
         ee:00:b9:1c:ad:e1:44:48:41:a4:77:55:8d:0a:c8:b0:bb:69:
         fe:9a:84:a5:cd:2d:a9:61:3b:60:92:e4:43:d6:2b:79:d6:5a:
         0d:db:f7:7f:7a:fc:7d:c3:59:e3:7d:d7:47:78:c2:b2:7d:6d:
         f2:7a:75:49
```

* * *

<br>

인증서 적용하기
========

CA bundle
---------

CA에서 인증서를 발급받으면 end-entity (내 서버에서 사용할 인증서)의 인증서만 오지 않는다. Root CA의 인증서와 Intermediate 인증서가 함께 오는데 이를 CA bundle이라고 한다. CA bundle은 웹 브라우저 등의 클라이언트와 인증서의 호완성을 높히기 위해서 사용이 된다.

<br>

```java
Root CA 인증서 + Intermediate 인증서 + end-entity 인증서 = Certificate Chain
```

<br>

CA bundle은 \*.ca-bundle 확장자의 zip 파일이나 root, intermediate 개별로 주어진다. 만약 개별로 주어졌을 경우에는 하나의 ca-bundle로 합쳐야 한다. CA bundle은 클라이언트에게 순차적으로 제공이 되어야 하기 때문에 대게는 CA에서 이미 하나의 bundle을 만들어서 제공해준다.

![](/assets/img/post/certificate/attachments/4565565736/4668522518.png)

<br>

하나의 번들로 제공해주지 않았을 경우 아래와 같이 간단하게 만들 수 있다.

example: 
*   AddTrustExternalCARoot.crt – Root CA Certificate
*   COMODORSAAddTrustCA.crt – Intermediate CA Certificate 1
*   COMODORSADomainValidationSecureServerCA.crt – Intermediate CA Certificate 2
*   yourDomain.crt – Your SSL Certificate


```java
cat ComodoRSADomainValidationSecureServerCA.crt ComodoRSAAddTrustCA.crt AddTrustExternalCARoot.crt > yourDomain.ca-bundle
```

<br> 

브라우저의 브라우징 창에 :lock: 모양을 누르면 해당 도메인에 대한 인증서의 종류, 상태 등을 볼 수 있는데 google.com의 인증서를 열어봤을 때에도 아래처럼 인증서가 계층을 이루고 있다.

1.  end-entity 인증서: \*.[google.com](http://google.com)
2.  Intermediate 인증서: GTS CA 1C3
3.  Root 인증서: GTS Root R1


![](/assets/img/post/certificate/attachments/4565565736/4665901319.png)  
![](/assets/img/post/certificate/attachments/4565565736/4666196141.png)  
![](/assets/img/post/certificate/attachments/4565565736/4666687519.png)  
 

<br>

#### CA Bundle 명시

CA Bundle은 어디에 명시를 해줘야 할까? CA bundle을 머신 어디엔가 다운로드해두었다면 해당 도메인이 등록되어있는 Nginx 등의 웹서버에 CA Bundle가 있는 path를 적어주면 된다. 그럼 알아서 클라이언트에게 CA Bundle을 한꺼번에 넘겨준다. 클라이언트는 이 Bundle을 통해서 end-entity가 믿을 수 있는지 없는지 여부를 결정한다. 이와 같은 과정을 **Chain of Trust**라고 한다.

<br>
example: Let’s encrypt 를 인증서로 사용했을 때 Nginx의 configuration

14번 줄의 의 fullchain.pem이 하나로 압축이 된 CA bundle이다. Let’s encrypt에서는 처음부터 하나로 압축된 ca-bundle을 pem 형식으로 제공해준다.

```java
server {

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name www.test.me test.me;

        location / {
                try_files $uri $uri/ =404;
        }

    listen [::]:443 ssl http2; # managed by Certbot
    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/test.me/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/test.me/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot




}
```

<br> 

Chain of Trust
--------------

### CA가 서명한 인증서의 내부 구조

CA가 서명을 end-entity의 인증서에 서명을 하게 되면 end-entity의 인증서에는 아래와 같은 정보가 추가되어 발급된다.

1.  누가 서명을 했는지 (Issuer name)
2.  Issuer의 Digital Signature (Issuer의 Private key로 서명)
3.  end-entity (Subject)의 public key


![](/assets/img/post/certificate/attachments/4565565736/4666720302.png?width=442)

Chain of Trust는 브라우저가 신뢰할 수 있는 CA가 Issuer로 있는 인증서를 찾기 까지 모든 layer의 인증서를 탐색하는 과정이라고 생각하면 된다. 다른 말로 신뢰할 수 있는 CA가 발급한 인증서를 증명하는 과정이다.

<br>

### Chain of Trust 과정

![](attachments/4565565736/4668096789.png)

> 브라우저에 Root CA의 인증서를 보내도 대부분은 그 인증서를 쓰지 않고, 브라우저에 이미 자체적으로 저장이 되어있는 Root CA 인증서를 사용한다.

<br>

1.  End-entity의 인증서 제출
2.  End-entity는 브라우저가 신뢰할 수 있는 CA가 아니다.
3.  누가 End-entity에 서명을 했는지 확인한다. Intermediate CA가 Issuer로 되어있다.
4.  Intermediate CA는 브라우저가 신뢰할 수 있는 CA가 아니다.
5.  누가 End-entity에 서명을 했는지 확인한다. Root CA가 Issuer로 되어있다.
6.  Root CA는 브라우저가 신뢰할 수 있는 CA다.
7.  Root CA의 digital signature를 브라우저가 이미 가지고 있는 Root CA의 public key로 verify한다.
8.  Root CA digital signature verify 완료.
9.  **Root CA → Intermediate CA → End-entity 모두 chain of trust를 통해서 믿을 수 있는 인증서가 된다.**

<br>

### Chain 계층 구조

![](/assets/img/post/certificate/attachments/4565565736/4668719189.png)

<br>

#### Root Certificate AKA Trust Anchor

1.  최상단인 Root는 보증해 줄 곳이 없기 때문에 Root CA는 직접 서명(self-signed)을 한다.
2.  clinet는 multi-level 의 chain of trust를 통해서 end-entity가 root (trusted source)에 인증이 되었는지 식별할 수 있다.
3.  Root의 Private key가 변경이 되었다면 해당 Private key로 발급받은 모든 인증서를 재발급 해야 한다. (Intermediate, end-entity 모두 포함)
4.  모든 Private key는 밖으로 노출되어서는 안되지만 Root CA의 Private key는 특히나 주의해야 한다. 때문에 Root가 end-entity에 직접 서명하는 일은 거의 없고, 중간에 하나 또는 여러 개의 Intermediate CA가 서명을 한다.
5.  OS, 서드파티 웹 브라우저, 클라이언트 어플리케이션은 100여개가 넘는 신뢰할 수 있는 Root CA의 인증서를 사전에 설치해둔다.

<br>

#### Intermediate Certificate

1.  거의 모든 SSL 인증서 chain에는 최소 하나의 Intermediate CA가 들어가 있다.
2.  Intermediate CA는 Root CA의 신뢰성(trustworthy)의 확장에 필수적인 연결점이고, Root CA와 end-entity에 추가적인 보안 레벨이 된다.


<br>

#### End-entity Certificate

1.  End-entity의 인증서는 보안, 확장성, CA compliance 등을 제공하지만, 인증서를 발급받은 대상 (subject)의 신뢰성을 보장하지는 못한다.
2.  End-entity는 크리티컬한 정보를 CSR에 담아 인증서를 발급해주는 CA(issuer)에게 제출하고, CA가 판단하기에 제출된 정보가 믿을 수 있다면 CA의 Private key로 서명을 한 인증서를 발급해준다.
3.  이 인증서가 verified 또는 signed 되어있지 않다면 SSL connection은 실패한다.

<br>
<br>

* * *

(plus)인증서가 사용되는 프로세스 모식도
========================

#### 브라우저와 서버의 request - response 과정 모식도

> 브라우저들은 root CA 들의 root 인증서를 이미 리스트로 가지고 있는 경우가 대다수이다.  

<br>

![](/assets/img/post/certificate/attachments/4565565736/4666294308.png)

<br>

1.  브라우저가 [youtube.com](http://youtube.com) 을 요청한다.
2.  youtube가 인증서 번들을 브라우저에 제출한다. (Google CA가 서명한 youtube의 public key가 포함되어있다)  
    \-> Root CA가 말단 인증서에 서명을 하는 경우는 거의 없기 때문에 Root CA 사이의 Intermediate CA 가 서명을 했을 것이다.
3.  브라우저는 이미 모든 메이저 CA의 public key를 설치해 둔 상태다. 브라우저는 이 CA public key로 서버가 제출한 인증서가 정말로 신뢰할 수 있는 CA에 의해 서명되었는지 확인한다.  
    \-> Intermediate CA는 지정된 Root CA가 아니기 때문에 브라우저의 입장에서는 믿을 수 없는 CA다.  
    \-> 제출된 인증서 번들을 타고 올라가서 Root CA까지 간다. 여기까지 확인 되어야 youtube가 제출한 인증서가 Root CA에 의해 서명되었다고 신뢰한다. TODO: 확인필요
4.  신뢰하기로 한 인증서에 명시되어있는 domain name이나 ip가 맞다면, 서버의 public key를 사용하여 대칭키를 생성하여 서버와 공유한다.
5.  이 대칭키로 connection의 모든 트래픽을 암호화한다. 대칭키를 사용하는 것이 비대칭키를 사용하여 모든 커뮤니케이션을 암호화하는 것보다 효율적이기 때문에 대칭키르르 사용한다.
6.  복호화는 private key를 가지고 있는 서버만 가능하다.

<br>

#### CA-signed 인증서 발급 과정 모식도

![](/assets/img/post/certificate/attachments/4565565736/4666196103.png)

<br>

#### Self-signed 인증서 발급 과정 모식도

![](/assets/img/post/certificate/attachments/4565565736/4666490918.png)
