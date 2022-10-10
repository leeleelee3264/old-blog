---
layout: post
title: "[Project] Python Version of Myinfo oauth2 Connector"
date: 2022-07-23 08:43:59
author: Jamie Lee
categories: Project
tags:	project
pagination:
enabled: true
---


프로젝트 github:[link](https://github.com/leeleelee3264/myinfo-connector-python)  
프로젝트 api document:[link](https://leelee-1.gitbook.io/myinfo-connector-python-api-doc/)  
프로젝트 quick start: [link](https://leelee-1.gitbook.io/myinfo-connector-python-api-doc/myinfo-connector-python-api/quick-start)

<br>

# About Singpass

싱가포르에는 정부 주도로 만들어진 Mydata 서비스인 Singpass가 있다. 정부가 주도한 Mydata 서비스가 몇 개의 나라에 있다고 하는데, Singpass는 그 중에서도 모범사례로 뽑힌다고 한다. Singpass는 싱가포르의 15세 이상의 시민중 97%가 쓰고 있는 아주 활발한 서비스이다.

Singpass에 있는 여러가지 서비스 중 Myinfo는 Person Data를 제공하는 서비스로, 한국의 카카오나 네이버 아이디 처럼 ouath2 로그인과 회원가입을 할 수 있다. Singpass에 대한 더 자세한 설명은 아래의 이미지로 대체하겠다.

![Untitled](https://github.com/leeleelee3264-api-docs/myinfo-connector-python-api-docs/raw/main/.gitbook/assets/image.png)

<br>

# Project

Singpass는 Myinfo를 손쉽게 사용할 수 있도록 Java와 node.js 버전의 connector를 제공하고 있다. Python 버전은 제공을 하고 있지 않아, 이번에 개인 프로젝트로 python 버전의 connector를 만들었다. 아예 하나의 완성된 형태로 제공을 하고 싶어서 Django를 사용해 REST API 형태의 connector를 만들었다.

## Project goal

프로젝트를 진행하면서 이루고자 한 목표는 아래와 같다. 대부분의 토이 프로젝트가 제대로 정리가 되어있지 않거나 코드가 엉망으로 짜여질 때가 많아서 이번에는 처음부터 확실하게 목표를 설정했다.

- DDD 아키텍처로 서버를 구현한다.
- 최소 2회의 리팩토링을 진행한다.
- python lint(flake8, pylint, mypy)를 사용하여 최대한 python style을 고수한다.
- Pipenv를 사용해서 python 패키지를 관리한다.
- 최대한 꼼꼼하게 문서화를 한다.
  - Github README를 작성한다.
  - API document를 작성한다.
  - Project에 대한 블로그 포스팅을 작성한다.

<br>


## Dev Stack

| stack  | info |
| --- | --- |
| Backend Language | Python  |
| Backend Framework | Django |
| Code Architecture  | Domain Driven Desgin |
| Python Package Managment | Pipenv |
| Security  | PKI |
| Version Control  | Github |
| API Document  | GitBook  |


<br>


## Myinfo oauth2

![Untitled](/assets/img/post/myinfo_oauth.png)


<br>


Myinfo는 이미지와 같은 oauth2 구조를 가진다.

- Resource Owner
  → Myinfo 사용자
- Application
  → 내가 구현하는 connector로, Myinfo 사용자의 데이터를 사용하는 주체
- Identify Providers / Service Authorization Platform
  → 인증서버
  → 사용자의 인증정보와 권한 정보를 소유한 서버
  → Singpass 로그인 페이지 제공
- Resource Server
  → 사용자 데이터를 소유한 서버
  → 인증 서버에 로그인 성공 후 접근



**Resource API from Myinfo**

- [authorise api]([https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getauthorise](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getauthorise)) 
- `GET /v3/authorise`
- [token api]([https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/gettoken](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/gettoken)) 
- `POST /v3/token`
- [person api]([https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getperson](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getperson)) 
- `GET /v3/person/{sub}`


<br>


## Make Request

Myinfo oauth2 구조를 반영하여, connector 서버의 호줄 fllow를 아래와 같이 설계했다.

![singpass.png](/assets/img/post/singpass.png)

<br>
 
### Step 1: Get myinfo(singpass) redirect login url

### Request

`GET /users/me/external/myinfo-redirect-login`

```
curl -i -H 'Accept: application/json' <http://localhost:3001/user/me/external/myinfo-redirect-login>
```

### Response

```
{
    "message": "OK",
    "data": {
        "url": "https://test.api.myinfo.gov.sg/com/v3/authorise?client_id=STG2-MYINFO-SELF-TEST&attributes=name,dob,birthcountry,nationality,uinfin,sex,regadd&state=eb03c000-00a3-4708-ab30-926306bfc4a8&redirect_uri=http://localhost:3001/callback&purpose=python-myinfo-connector",
        "state": "eb03c000-00a3-4708-ab30-926306bfc4a8"
    }
}

```

<br>

### Step 2: Browse myinfo redirect login

```
curl <https://test.api.myinfo.gov.sg/com/v3/authorise?client_id=STG2-MYINFO-SELF-TEST&attributes=name,dob,birthcountry,nationality,uinfin,sex,regadd&state=eb03c000-00a3-4708-ab30-926306bfc4a8&redirect_uri=http://localhost:3001/callback&purpose=python-myinfo-connector>

```

<br>

### Step 3: Do login and check agree terms

### Myinfo Login Page

![Untitled](https://camo.githubusercontent.com/f182742864359f6e9805e719a3385f933d6573fc513b52775b4cfe3bed24ffcc/68747470733a2f2f333832303939333537342d66696c65732e676974626f6f6b2e696f2f7e2f66696c65732f76302f622f676974626f6f6b2d782d70726f642e61707073706f742e636f6d2f6f2f7370616365732532466c496e76414f684638715879534552494938455825324675706c6f6164732532464536496a746441704f3259345668304a6d763746253246254531253834253839254531253835254233254531253834253846254531253835254233254531253834253835254531253835254235254531253836254142254531253834253839254531253835254133254531253836254241253230323032322d30372d323325323025453125383425384225453125383525413925453125383425384325453125383525413525453125383625414225323031302e31382e35312e706e673f616c743d6d6564696126746f6b656e3d61356465613939372d656161362d346539372d613664322d333464343438373463313734)

### Myinfo Terms Agreement Page

![Untitled](https://camo.githubusercontent.com/39e35bf85ce639345ebb9274a0978272542465c4b71d0e89ceb6f9cd251fb79e/68747470733a2f2f333832303939333537342d66696c65732e676974626f6f6b2e696f2f7e2f66696c65732f76302f622f676974626f6f6b2d782d70726f642e61707073706f742e636f6d2f6f2f7370616365732532466c496e76414f684638715879534552494938455825324675706c6f61647325324630526b63314c6f44546a5a4e364d656c57316136253246254531253834253839254531253835254233254531253834253846254531253835254233254531253834253835254531253835254235254531253836254142254531253834253839254531253835254133254531253836254241253230323032322d30372d323325323025453125383425384225453125383525413925453125383425384325453125383525413525453125383625414225323031302e31392e33352e706e673f616c743d6d6564696126746f6b656e3d38613537643731392d393333332d343061662d386662632d616635363662393134343731)

<br>

### (Automated) Step 4: Callback API get called by Myinfo

Myinfo에 로그인을 하고 terms에 동의를 하면 Myinfo에서 myinfo-connecotr-python의 callback API를 호출해 auth code를 넘겨준다.
myinfo auth code API:  [myinfo's authorise API](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getauthorise)

### callback url example

```
<http://localhost:3001/callback?code=8932a98da8720a10e356bc76475d76c4c628aa7f&state=e2ad339a-337f-45ec-98fa-1672160cf463>

```

### callback response HTML example

![Untitled](https://camo.githubusercontent.com/f4b5b1eaa871876c63d801411444637001c07491091f731ebbafdd36865ebeac/68747470733a2f2f333832303939333537342d66696c65732e676974626f6f6b2e696f2f7e2f66696c65732f76302f622f676974626f6f6b2d782d70726f642e61707073706f742e636f6d2f6f2f7370616365732532466c496e76414f684638715879534552494938455825324675706c6f61647325324641523347636e3571474c7733584a4f64446b5549253246254531253834253839254531253835254233254531253834253846254531253835254233254531253834253835254531253835254235254531253836254142254531253834253839254531253835254133254531253836254241253230323032322d30372d323325323025453125383425384225453125383525413925453125383425384325453125383525413525453125383625414225323031302e33322e33342e706e673f616c743d6d6564696126746f6b656e3d38386462353065332d633933372d343831642d393365312d306536396234633763313662)

<br>

### (Automated) Final Step: Get Person data from Myinfo

Myinfo의 callback 이후, callback 페이지는 자동으로 myinfo-python-connector의 person data API를 호출하도록 했다. 해당 API가 Myinfo에서 사용자 정보를 가져오는 마지막 단계이다.

### Callback page의 Person data API 자동호출 부분

```html
<script>
    window.addEventListener('load',
        function (event) {
            let code_element = document.getElementById('code-container')
            let code_text = code_element.innerHTML

            let url = `http://localhost:3001/users/me/external/myinfo?code=${code_text}`
            window.location.href = url
        }
    );
</script>
```

<br>

### Request

`GET /users/me/external/myinfo`

```
curl -i -H 'Accept: application/json' <http://localhost:3001/user/me/external/myinfo>
```

### Response

```
{
    "message": "OK",
    "sodata": {
        "regadd": {
            "country": {
                "code": "SG",
                "desc": "SINGAPORE"
            },
            "unit": {
                "value": "10"
            },
            "street": {
                "value": "ANCHORVALE DRIVE"
            },
            "lastupdated": "2022-07-14",
            "block": {
                "value": "319"
            },
            "source": "1",
            "postal": {
                "value": "542319"
            },
            "classification": "C",
            "floor": {
                "value": "38"
            },
            "type": "SG",
            "building": {
                "value": ""
            }
        },
        "dob": "1988-10-06",
        "sex": "M",
        "name": "ANDY LAU",
        "birthcountry": "SG",
        "nationality": "SG",
        "uinfin": "S6005048A"
    }
}

```

<br>

## PKI Digital Signature

Myinfo는 PKI Digital Signature를 필요로 한다. 해당 문서에서는 python에서 PKI를 사용하는 방법만을 다루기 때문에 PKI에 대한 더 자세한 설명은 링크로 첨부하겠다. [[Security] Digital Certificate](https://https://leeleelee3264.github.io-old//infra/2022/06/15/digital-certificate-part-one.html)

이 프로젝트에서는 Myinfo에서 샘플로 제공하는 client private key와 myinfo public key를 사용했다. 샘플환경에서는 client의 public key는 이미 myinfo에서 가지고 있다고 가정되어있기 때문에 myinfo에 별도로 clinet public key를 전달하지 않아도 된다. python 패키지로는 *`jwcrypto`*와 `Crypto`를 사용했다.

key를 사용하는 시나리오는 아래와 같다.

client private key

- [myinfo token api]([https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/gettoken](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/gettoken))를 호출할 때
- [myinfo person api]([https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getperson](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getperson))를 호출 할 때
- [myinfo person api]([https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getperson](https://public.cloud.myinfo.gov.sg/myinfo/api/myinfo-kyc-v3.2.2.html#operation/getperson)) 응답 decrypt 할 때  
  → myinfo에서 client의 public key로 응답을 암호화 했기 때문

myinfo public key

- myinfo token api 응답 verify 할 때  
  → myinfo에서 myinfo의 private key로 응답을 암호화 했기 때문
- myinfo person api 응답 verify 할 때  
  → myinfo에서 myinfo의 private key로 응답을 암호화 했기 때문

<br>

**public, private** **Key 불러오기**

```python
from jwcrypto import jwk

PrivateKey = jwk.JWK
PublicKey = jwk.JWK
    

def _get_key(self, key: str) -> Union[PrivateKey, PublicKey]:
        encode_key = key.encode('utf-8')
        key_dict = jwk.JWK.from_pem(encode_key)

        return key_dict
```

<br>

**client private key로 서명하기**

```python
import base64
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA
from Crypto.Signature import PKCS1_v1_5

Signature = str

def _sign_on_raw_header(
            self,
            base_string: str,
            private_key: str,
    ) -> Signature:

        digest = SHA256.new()
        digest.update(
            base_string.encode('utf-8'),
        )

        pk = RSA.importKey(private_key)
        signer = PKCS1_v1_5.new(pk)
        signature = str(base64.b64encode(signer.sign(digest)), 'utf-8')

        return signature
```

<br>

**client private key로 응답 decrypt 하기**

```python
import json
from jwcrypto import (
    jwe,
    jwk,
)

PrivateKey = jwk.JWK

def _decrypt(
            self,
            encrypted_payload: str,
            key: PrivateKey,
    ) -> DecryptedPersonData:

        params = self._get_decrypt_params(encrypted_payload)

        encryption = jwe.JWE()
        encryption.deserialize(params, key)

        data = encryption.plaintext
        data_str = json.loads(data)

        return data_str
```
<br>

**myinfo public key로 응답 verify 하기**

```python
import json
from jwcrypto import jwk
   

PublicKey = jwk.JWK
DecodedPersonData = dict

def _decode(
            self,
            encoded_payload: str,
            key: PublicKey,
    ) -> DecodedPersonData:

        token = jwt.JWT()
        token.deserialize(jwt=encoded_payload, key=key)

        data = token.claims
        data_dict = json.loads(data)

        person = DecodedPersonData(**data_dict)
        return person
```


<br>

<hr>


# Project를 마치며

정해둔 목표를 잘 이행한 기분이 들어서 뿌듯했다. 또한 항상 미흡했던 문서화를 꼼꼼하게 해 둔 거 같아 만족스럽다. 하지만 문서화를 하는 과정에서 어떻게 더 내가 말하고자 하는 바를 선명하게 글로 옮길 수 있을까 고민을 많이 했고, 아직도 부족한 부분이 많이 보인다.

코드 또한 2번 리팩토링을 진행했지만 포스팅을 위해서 다시 코드를 보니 또 리팩토링 해야겠다는 생각이 든다. 어떤 프로젝트를 하더라도 프레임워크 setting을 하는데 초기 시간을 많이 소요하는데, 앞으로 Django로 계속 프로젝트를 진행할 예정이라면 pre-setting이 다 되어있는 Django-to-go 를 만들어야겠다.
