---
layout: post
title: "[Career] 2021 Backend Engineer Interview - Python, General"
date: 2021-12-02 08:43:59
author: Jamie Lee
categories: General
tags:	interview
cover:  "/assets/img/banff.jpg"
pagination:
enabled: true
---

<br> 

> 2021 하반기 기술면접에서 나온 질문들과 소감을 정리한 포스팅 2편 입니다.
>

<br> 
<br> 

전편 [[2021 Backend Engineer Interview - Java]]([https://leeleelee3264.github.io/general/2021/12/02/interview-java.html](https://leeleelee3264.github.io/general/2021/12/02/interview-java.html)) 에 이어서 이번에는 Python과 약간의 DevOps, 개발 전반 상식에 대한 면접 질문을 정리했다.

index

1. Python
   1. 쓰레드
   2. 동시성
   3. Django 모듈 구조와 흐름
   4. Django ORM
2. DevOps
   1. Nginx load balancing 스케쥴링 알고리즘
   2. 쿠버네티스 파드
   3. 도커 컴포즈
3. 개발 전반 상식
   1. DDD
   2. DAO와 DTO, ENTITY의 차이
   3. Request에서 GET과 POST의 차이
   4. Cross Origin Resource Sharing
   5. 어센틱케이션과 어쏠리제이션의 차이
   6. 스키마를 짤 때 하는 고민
   7. 고수준 인터페이스와 저수준 인터페이스

---
<br> 
<br> 

# Python

## 파이썬 쓰레드

파이썬 쓰레드에 대해 아는 점은 파이썬 자체에서 쓰레드를 지원하는 것은 아니고, 운영체제에서 제공하는 쓰레드를 사용한다는 것과, 쓰레드가 있다고 해도 한 타임에 한 쓰레드만 돌아간 다는 사실이었다. 이러한 특성의 원인은 파이썬의 디폴트 구현채인 CPython에 있었다.

- Cpython은 OS 쓰레드를 사용한다. 파이썬 쓰레드란, OS 쓰레드를 파이썬이 런타임에 관리를 하는 것 뿐이다.
- Cpython 인터프리터는 전역 인터프리터 록 (global interpreter lock) 메커니즘을 사용한다. 이는 **한 번에 오직 하나의 스레드가 파이썬 바이트 코드를 실행하도록 보장**한다. 이런 인터프리터 전체를 잠그는 특성은 인터프리터를 다중스레드화 하기 쉽게 만들지만, **한 번에 단 하나의 쓰레드를 실행시켜 쓰레드의 특징인 병렬성 잃어버리게 한다**. (이는 multiprocessing 으로 보완)

파이썬 쓰레드에 대해 너무 간략하게 알고 있었기 때문에 추가로 더 찾아보게 되었는데, 그때 프로그래밍에서 흔히 사용되는 개념인 동시성과 병렬성에 대해서, 또 파이썬은 이 둘을 어떻게 지원하는지 학습했다.

<br> 

## 파이썬의 동시성과 병렬성

원래는 동시성과 병렬성이 같은 뜻인줄 알았다. 알고보니 동시성은 짧은 시간에 한 가지 일을 처리 하고 금방 바꿔서 또 다른 일을 처리하는 걸 말한다. 결국 한 순간에는 한가지 일만을 처리하고 있다. 그런데 병렬성은 한 순간에 여러가지 일을 처리하고 있다.

![스크린샷 2021-12-21 오후 10.51.56.png](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F89e21853-3ee9-4f61-af38-7d2565721d96%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2021-12-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_10.51.56.png?table=block&id=a7b7d750-8798-4681-a34c-1764bb33c3bf&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

그런데 병렬성이 빛을 보기 위해서는 정말로 CPU 여러 개가 있어야 한다. 여러 가지 CPU들에 일을 하나씩 할당해 마치도록 하기 떄문이다. 여러가지 일을 한 번에 처리하는 병렬성이 좋아보이지만, 어떤 일을 처리하냐에 따라서 동시성과 병렬성을 선택해야 한다. 대기하는 일이 대부분인 입출력 I/O 작업이라면 병렬을 해서 CPU를 놀게 하는 것보다는 동시성을 사용하는 게 더 효과적이다. 이제 실제 파이썬 구현 부분을 봐보도록 하자.

동시성

- Python threading

  장점: 편리하고, 잘 이해되는 방법으로 다른 리소스들을 기다리는 테스크를 실행한다. 여기서의 리소스들은 네트워크, 입출력, 하드웨어 디바이스의 신호 등이 될 수 있다.

  단점:  General한 쓰레드의 단점들처럼, 객체 엑세스를 잘 관리해줘야 해서 CPU에 민감한 작업은 할 수 없다. 또한 실행되고 있던 A 쓰레드가 B 쓰레드로 스위치 되면서 A 쓰레드는 멈춰버리기 때문에 쓰레드를 사용하는 퍼포먼스적 이점이 없다.

- Python Coroutine and async

    ```python
    import aiohttp
    import asyncio
    
    urls = [
        "https://imdb.com",    
        "https://python.org",
        "https://docs.python.org",
        "https://wikipedia.org",
    ]
    
    async def get_from(session, url):
        async with session.get(url) as r:
            return await r.text()
    
    async def main():
        async with aiohttp.ClientSession() as session:
            datas = await asyncio.gather(*[get_from(session, u) for u in urls])
            print ([_[:200] for _ in datas])
    
    if __name__ == "__main__":
        loop = asyncio.get_event_loop()
        loop.run_until_complete(main())
    ```

  코루틴과 async 를 파이썬에서 아예 처음봐서 코드를 가져왔다.  코루틴의 실행 루틴은 이렇게 진행이 된다.

  - get_from 함수가 코루틴이다.
  - asyncio.gather 는 여러개의 코루틴 (다른 url들을 가진 다수의 get_from 함수 인스턴스) 를 생성해낸다.
  - asyncio.gather 는 모든 코루틴이 실행 완료되기를 기다렸다가, 결과를 취합해서 리턴한다.



    장점: 어떤 게 코루틴인지 문맥적으로 확실하게 구분을 할 수 있다. 쓰레드를 사용하면 어떤 함수도 쓰레드로 돌아갈 수 있어 혼동이 오는 데 코루틴은 그 점을 방지한다. 또한 코루틴이 꼭 쓰레드를 필요로 하지 않는다고 한다. 코루틴은 파이썬 런타임이 직접 관리를 할 수 있다. 스위칭이 될 때에도 쓰레드보다 오버헤드도 작고, 메모리도 더 적게 필요로 한다.  
    
    단점: async await 문법을 잘 지켜야 한다. 또한 쓰레드가 그러하듯, CPU에 민감한 작업은 할 수 없다. 


병렬성

- Pyhon multiprocessing

  말 그대로 프로세스를 여러 개 만드는 것이다. 각각의 CPU에서 돌아가기 때문에 멀티코어여야 한다. **프로세스를 여러개 만든 다는 말은 파이썬 인터프리터 인스턴스를 여러개 만든 다는 뜻이다**!

  장점: 쓰레드와 코루틴과는 다르게 객체의 다중 엑세스에 대한 관리가 조금 더 쉽다. 그리고 쓰레드와 코루틴은 다중 엑세스 때문에 모든 오퍼레이션이 순차적으로 돌아가게 하지만 이는 그럴 필요가 없다.

  단점: 프로세스를 여러개 만드는 것 자체에 오버해드가 든다. 그리고 서브 프로세스들은 메인 프로세스에서 온 데이터 복사본이 있어야 하는데 이렇게 프로세스 사이에서 데이터가 왔다갔다 하기 위해서는 직렬화를 해야 한다. 이때 pickle 파이썬 라이브러리를 쓰는데, 보통의 객체들은 지원하지만 특이한 객체들은 지원을 하지 않는다.


이 포스팅을 보면서 파이썬이 지원하는 동시성, 병렬성 구현을 살펴봤다.

[Python concurrency and parallelism explained](https://www.infoworld.com/article/3632284/python-concurrency-and-parallelism-explained.html)

<br> 

## 파이썬을 백엔드로 쓰면서 한꺼번에 몰린 요청을 처리하는 방법

이건 면접에서 나온 질문은 아니었고, 내가 궁금해서 물어본 부분이었다. 파이썬은 인터프리터 언어다보니 백엔드로 사용을 하다보면 한계가 온다고 한다. 그래서 결국 컴파일 언어인 자바로 다시 만드는 경우가 왕왕있다고 하는데 한꺼번에 요청이 몰리면 어떻게 파이썬으로 처리를 하냐고 물어봤다.

백엔드 코드를 쿠버네티스에 올려서 운용을 한다고 말씀해주셨는데, 그래서 요청이 몰릴때에도 이 쿠버네티스에 올린 파드를 증설한다고 한다. 즉, 컨테이너를 몇 개 더 만들어 요청을 분산처리 한다. 역시 코드 자체로 성능을 개선하기 보다는 돈을 써서 서버를 증설하는 방법이 회사에서 제일 많이 사용되는 방법이 아닐까.

<br> 

## Django 모듈 구조와 흐름

![Untitled](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F465a05b9-db52-49b3-bc64-126f8fa8f85c%2FUntitled.png?table=block&id=8218b060-6268-4212-b14d-87eed3505170&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

장고의 흐름은 아래와 같다. 굉장히 간단한 질문이었는데 장고를 거의 사용하고 있지 않아서 아주 뜨문뜨문 대답을 했다.. 한창 스프링을 쓰고 있었기 때문에 스프링에 빚대어서 대답을 했다.

View - Controller

Model - 데이터가 들어있는 엔티티, 장고의 모델의 필드들은 db 테이블의 컬럼들과 매핑이 된다. db와 바로 연결이 되어있기 때문에 (장고 설정을 어떻게 했냐에 따라 다르겠지만) 모델을 변경하면 자동으로 db에 migrate 될 수 있다.

Template - 화면이다. mvc 패턴을 사용하지 않았다면 쓸 일이 거의 없다.

![스크린샷 2021-12-21 오후 10.33.55.png](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F2ff7701f-b034-4dce-9cf8-23cf9c7da9c3%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2021-12-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_10.33.55.png?table=block&id=f5dc046d-2528-4d2b-a044-5ddec3cb4ab0&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

항상 **프로젝트 안의 wsgi가 뭔가 했는데 웹 서버 및 어플리케이션을 위한 파이썬 표준이라고** 한다. 클라이언트가 정적인 웹페이지를 요청했을 경우 웹서버에서 쳐 낼 수 있지만, 동적인 페이지를 요청했을 때는 웹서버에서 처리를 할 수 없고, 장고 서버에 리퀘스트를 넘겨줘야한다. 그런데 웹서버는 파이썬을 모른다. 그렇기 때문에 가운데에 wsgi가 인터페이스 역할을 해서 웹서버와 장고를 연결해준다.

그럼 당연히 장고에서 제일 먼저 호출되는 부분은 wsgi가 될 수 밖에 없다. 얘가 리퀘스트를 물어다주니까. url 디스패처와 미들웨어 등등도 일단은 리퀘스트를 받아와야 해서 그 이후에 호출이 된다.

<br> 

## Django ORM objects.all, select_related, prefetch_related

objects.all 은 전체 자료를 불러온다. 모든 데이터가 필요하지 않은 이상 제일 효율이 좋지 않은 쿼리라 할 수 있다.

Django ORM에서 쿼리 성능 향상으로 많이 쓰이는 기능은 select_related 와 prefetch_related인데 둘 다 즉시 로딩 (Eager-loading)과 join으로 연관되어있는 데이터를 한꺼번에 끌어오기, **한 번 DB에서 로딩을 한 이후부터는 캐싱**이 되어서 쓰이는 등의 특징은 동일하지만 사용하는 상황이 조금 다르다.



select_related는 one-to-one 같은 single-valued relationship 에서만 사용이 가능하다. 반면 prefetch_related는 one-to-one도 가능하고 many-to-many, many-to-one에서도 사용이 가능하다. 그런데 prefetch_related는 데이터를 join해서 가져오는 과정이 DB에서 join을 해서 가져오는 select_related와는 조금 다르다.

1. 관계별로 개별 쿼리를 실행 (연결 테이블이 3개라면 3개의 쿼리가 따로 실행)
2. 각각 가져온 데이터들을 파이썬에서 합쳐주기

select_related와 prefetch_related에 대한 차이를 잘 설명해주고 있다. select_related와 prefetch_related를 함께 사용하는 방법도 있다.

[select_related와 prefetch_related](https://jupiny.tistory.com/entry/selectrelated%EC%99%80-prefetchrelated)

Django Prefetch 효율적 사용으로 성능개선하기 (ORM을 좀 쓰다가 보면 좋을 것 같다)

[당신이 몰랐던 Django Prefetch.](https://medium.com/chrisjune-13837/%EB%8B%B9%EC%8B%A0%EC%9D%B4-%EB%AA%B0%EB%9E%90%EB%8D%98-django-prefetch-5d7dd0bd7e15)

---

<br> 
<br> 

# DevOps

## Nginx load balancing 스케쥴링 메서드

Nginx에서 사용하는 load balancing 스케쥴링 메서드들은 아래와 같다.

1. Round Robin

   라운드 로빈은 운영체제 수업에서 배웠던 라운드 로빈과 동일한 알고리즘으로, 아무런 설정을 하지 않았다면 기본적으로 라운드 로빈 방식으로 스케쥴링이 된다.

2. Least Connections
   가장 적은 수의 active connection을 가지고 있는 서버에게 요청을 할당한다.
3. IP Hash
   똑같은 아이피에서 온 요청들을 똑같은 서버에서 처리할 수 있도록 보장한다. 동일 아이피의 기준은 IPv4일때는 앞의 3 옥텟이 동일해야 하고, IPv6에서는 모든 자리가 동일해야 한다.
4. Generic Hash
   유저가 정의한 키(hashed key value) 에 맞춰서 요청을 할당한다고 한다.

<br> 

## 쿠버네티스 파드

쿠버네티스에서 생성하고 관리할 수 있는 배포 가능한 가장 작은 컴퓨팅 단위. 하나 이상의 컨테이너 그룹이다. 이 그룹은 스토리지 및 네트워크를 공유한다. 도커 개념 측면에서 파드는 공유 네임스페이스와 공유 파일시스템 볼륨이 있는 도커 컨테이너 그룹과 비슷하다.

<br> 

## Docker Compose

도커를 실행하기 위해서는 도커 커맨드를 사용해야 하는데 간단한 커맨드는 상관이 없지만 볼륨을 연결하는 등의 추가 설정을 하다 보면 커맨드가 굉장히 길어진다. 이렇게 길어진 도커 커맨드를 쉘 스크립트로 짜도 되지만 이런 불편을 도커 컴포즈를 이용해 해결 할 수 있다.

도커 컴포즈는 일종의 툴인데 도커 컨테이너 실행 환경을 YAML 파일로 관리할 수 있다.

```docker
version: "3.3"

services:
        # db config
        web:
            build: .
            ports:
              - "4012:4012"
            environment:
                 TZ: "Asia/Seoul"
            container_name: gov-prod-web_1
```

---

<br> 
<br> 

# 개발 전반 상식

## DDD

디자인 패턴중 하나이다.  모든 소프트웨어 디자인 패턴의 목적은 시스템을 만들고 유지보수하는데 투입되는 인력 최소화에 있다.

Domain Driven Design. 보통 클린 아키텍처랑 함께 사용된다. 도메인 코드가 어플리케이션과 인프라 코드와 분리 되는 것에 집중을 한다는 점이 같기 때문이다. 여기서 도메인이란 프로젝트 안에서 개발되어야 하는 주제를 뜻하며, 비즈니스 로직이라 할 수 있다.

DDD 를 보다보면 유비쿼터스라는 단어가 많이 나온다. 개발자, 디자이너, 기획자가 모두 동일한 의미로 이해하는 단어라는 뜻이다. DDD 패턴은 비즈니스 로직인 도메인을 인프라와 어플리케이션(서비스) 와 분리하기 때문에 비즈니스 자체에 집중을 할 수 있다. 그래서 개발자가 다른 부서와 협업을 할 때 의사소통이 더 원활하게 이뤄질 수 있다. (db, network 등등의 로우 레벨 을 얘기하지 않기 때문)

![스크린샷 2021-12-21 오후 9.18.29.png](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb46db34c-7fff-4bc2-9418-ed0a065ca148%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2021-12-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_9.18.29.png?table=block&id=75ba8884-bbbf-4897-bb3d-b402b310b1fd&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

도메인 개념에 집중해서 아키텍처를 만들면 위의 그림과 같다. 도메인 속에 엔타티가 들어있는데 이게 제일 중요한 개념이라고 생각한다. 엔티티에 최대한 많은 비즈니스 룰을 담아서 응집성을 높이고, 중복코드를 줄이는게 ddd의 목표이다. **단! 엔티티 밖의 메소드 (예를 들어 어플리케이션 레이어) 가 엔티티의 값을 변경하는 일은 절대 없어야 한다. 이는 객체지향에서 추구하는 캡슐화와 유사하다고 볼 수 있다**.

엔티티의 일은 엔티티 안에서 끝이 나야 한다!

![스크린샷 2021-12-21 오후 9.39.25.png](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F737f3e02-6711-4440-9f75-33aec65ccd18%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2021-12-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_9.39.25.png?table=block&id=3de9c25e-25fe-4658-ad1c-687e4e80d3f5&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

MVC 패턴에서도 DDD에서도 서비스의 역할을 정하는 게 가장 어렵다. 조금만 잘못해도 코드가 서비스에 치중을 해 결국 서비스에서 엔티티의 값도 바꾸고, DB에 저장 요청도하는 거대한 서비스 중심이 될 수 있기 때문이다. DDD 에서 서비스 (또는 use case) 의 역할은 여러가지 엔티티가 함께 다뤄져야 할 때이다. (여러가지 엔티티가 함께 다뤄지지 않아도 Controller 영역에서 바로 엔티티를 호출해서는 안된다)

<br> 

## DAO와 DTO, ENTITY의 차이

DAO는 Data Access Object 로, 데이터에 엑세스하기 위한 객체다. 정말 데이터를 얻어오기 위해 접근을 하는 객체라 다른 말을 할 것이 없다. **DAO 볼때마다 드는 생각이 그럼 Repository 는 뭐지?** 둘의 차이는 아래와 같다.

![스크린샷 2021-12-21 오후 10.07.05.png](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F2d8729b8-5138-4945-9da1-c1996c0425e7%2F%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2021-12-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_10.07.05.png?table=block&id=d2ba0a1f-7391-4b6b-8418-8ce940f61c6a&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

레포지토리가 더 상위계층이고 DAO가 하위계층이다. 레포지토리는 도메인과 데이터 매핑 레이어 가운데에 있는 존재이다. DAO 는 말 그대로 못생긴 쿼리를 한 번 숨기는 역할을 하고, 레포지토리는 여러가지 DAO를 활용해서 데이터를 상위 계층으로 전달을 할 수 있다.

DTO는 Data Transfer Object로, 데이터를 여러 계층 사이로 전송하기 위한 객체다. 스프링관점으로 생각을 해보자면 DAO가 DB에서 가져온 정보를 서비스 계층으로 넘길 때 DTO 에 넣어서 전송을 하고, 서비스 계층이 컨트롤러 계층으로 넘길 때 DTO를 사용한다 .

Entity 는 DDD의 관점에서 보면 비즈니스 로직이고, JPA로 보면 DB테이블 그 자체이다. 이렇게 중요한 부분 그 자체이기 때문에 변경도 엔티티 안에서 일어나야 하고, 다른 계층으로 넘길때도 그냥 넘겨서는 절대 안된다. 꼭 DTO에 담아서 전달을 해 줘야 한다.

<br> 

## Request에서 GET과 POST의 차이



GET은 데이터를 조회하기 위한 요청으로, 몇번을 반복적으로 요청해도 받아보는 데이터에 변화가 없다는 게 중요한 점이다. 이런 GET의 성격 때문에 무엇인가를 바꾸려는 작업을 GET으로 만들지 말아야 한다.

POST는 무엇인가를 바꾸기 (update/insert/delete) 위한 요청으로, 같은 요청을 여러번 날리다보면 사이드 이펙트가 발생할 수 있다.

POST가 GET보다 보안상 안전하다. GET은 URL안에 모든 정보를 다 포함하고 있기 때문에 웹서버 등지에서 엑세스 로그를 남길 경우 GET에 있던 정보들이 그대로 남게 된다. POST 또한 데이터를 URL에 넣지 않고 body에 넣었단 차이만 있을 뿐이고, 이 body도 까서 볼 수 있기 때문에 마냥 안전하다고 볼 수 없다. **민감한 데이터는 어지간하면 네트워크를 타고 움직이지 않는 것이 제일 좋다**.



이렇게 GET처럼 똑같은 요청(연산)을 여러번 하더라도 결과가 달라지지 않는 성질을 멱등성(Idempotent)라고 한다.  **Rest api에서 제일 많이 사용되는 메서드들 중에서 POST를 제외한 GET, PUT, DELETE은 멱등성을 지켜야 함을 명심하면서 서버 구현을 하도록 해야 한다.**

![Untitled](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fca6813e8-bad2-44e9-8735-a1003b84c518%2FUntitled.png?table=block&id=4dded598-ecc2-4246-97ea-015031993672&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1160&userId=&cache=v2)

처음에 HTTP 메서드들을 배웠을 때 POST와 PUT 구분이 어려웠다. 결국 POST나 PUT 둘 다 CREATE이 가능하기 때문에. 그런데 찾아보니 아래와 같은 사항으로 구분을 할 수 있다.

**멱등성**

POST= (a++)⇒ 계속 1이 증가하여 결과 값이 매번 달라진다.

PUT= (a=4) ⇒ 계속 a는 4로 업데이트 되기 때문에 결과값이 매번 같다.

**리소스 결정권 (CREATE의 상황일 때)**

리소스 결정권은 클라이언트가 이 리소스의 위치 (리소스 id)를 정확히 아는지 모르는지의 차이다.

```bash
POST /articles 
PUT /articles/11120 
```

PUT은 클라이언트가 리소스가 어디에 저장이되는지 정확히 알 수 있다. 내가 많이 쓰던 path variable 이 들어간 URL이 사실은 PUT에 맞는 컨벤션이었다. 반면 POST는 해당 URL을 요청하기만 하면 원하는 리소스를 만들어주겠다며 factory만 제공해주고 있다.

<br> 

## Cross Origin Resource Sharing

줄여서 CORS라고 한다. 위키사전에서 찾아봤을 때 교차 출처 리소스 공유라고 직역을 하고 있다.

원래 내가 알고 있던 부분은 같은 출처가 아닌, 다른 출처에서 리소스 요청을 했을 때 보안상 요청을 처리하지 못하고 error를 보낸다 였다. 그래서 이 문제를 해결하기 위한 정책이 CORS이고. 그런데 내가 심각하게 오해하고 있던 부분은, **여기서의 Origin이 서버를 의미하는 게 아니라 요청을 보낸 클라이언트를 의미하는 것 이었다**.



RFC에 존재하는 리소스 요청 정책은 2가지 이다. 하나는 SOP (Same-Origin Policy) 이고 다른 하나는 CORS이다. 하지만 이 정책들은 브라우저에 구현되어있는 스펙이다! 한 마디로

1. 서버와 서버가 리소스를 주고 받을 때는 CORS 문제가 발생하지 않는다.
2. 서버에서 응답을 주더라도 브라우저 단에서 응답을 막고 error를 내려준다.

때문에 서버 로그에서는 정상적으로 응답이 내려갔다고 보이면 디버깅이 상당히 어려워진다.  때문에 **서버에서도 CORS의 존재에 대해 염두해 두고 있어야 한다!**

![Untitled](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F61c41db4-0324-4deb-bfee-cce12ea7af7c%2FUntitled.png?table=block&id=98c8ce39-acd4-450d-912f-e1eb4c12063c&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1310&userId=&cache=v2)

MND에 써있는 설명이 제일 명확했다. 브라우저는 스크립트가 요청을 보낼 때 지금 스크립트가 서비스 되고 있는 url과 요청을 보내는 url을 비교한다. **여기서 동일한 url로 보여지는 조건은 프로토콜/스키마 (https, http) 와 호스트 (www.google.com) 포트번호가 모두 같을 때 동일한 url로 인정한다.**

클라이언트에서 발생하는 문제이지만 이걸 해결하기 위해서는 서버가 작업을 해야 한다. 해당 리소스에 대해 어떤 origin들이 요청을 할 수 있는지 응답 헤더중 하나인 Access-Control-Allow-Origin에 기입을 해주는 것이다. 여기에 와일드 카드를 넣어버릴 수 있지만 이럼 언제나 보안 문제가 일어날 수 있음을 명심하자. Access-Control-Allow-Origin에 들어있는 Origin들과 요청을 보냈던 클라이언트의 Origin을 보고 브라우저가 유효한 응답임을 판단한다.

CORS가 동작하는 시나리오는

1. Preflight
2. Simple Request
3. Credentialed Request

세가지가 있다. 어떻게, 어떤 조건에서 헤더를 채워서 보내는지에 따라 브라우저가 임의로 하나의 시나리오를 보내 요청을 보낸다. 어떤 조건속에서 어떤 CORS 시나리오가 만들어지는지 잘 유념하자.

[Cross Origin Resource Sharing - CORS](https://homoefficio.github.io/2015/07/21/Cross-Origin-Resource-Sharing/)

[CORS는 왜 이렇게 우리를 힘들게 하는걸까?](https://evan-moon.github.io/2020/05/21/about-cors/)

Options 메소드가 언제 쓰이는지 궁금했었는데 이렇게 access-control-allow-origin 을 알기 위해 선행 요청을 보낼 때도 사용이 된다고 한다.

![Untitled](https://gabby-zenobia-c10.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fa7a14206-d98c-4549-b81a-86f10527f8a5%2FUntitled.png?table=block&id=8b79cd3e-1a95-47f5-a785-db1192f0ad74&spaceId=95c8c354-996d-4b5f-8491-4b7297dbf7e7&width=1280&userId=&cache=v2)

<br> 

## Authentication 과 Authorization의 차이

Oauth2에 대해 대답을 하다가 나온 문제였다. 둘이 어떤 개념인지는 알지만 용어적으로 낯설어 제대로 대답을 하지 못 해 이번에 정리를 하면서 찾아봤다. Authentication과 Authorization을 쉽게 비교하기 위해 표를 작성했다.

| / | Authentication | Authorization |
| --- | --- | --- |
| 역할 | 사용자 신원 확인 | 리소스, 기능 에 대한 엑세스 권한 확인 |
| 목적 | 사용자가 누구인지 확인/판별 | 사용자가 해당 리소스/기능에 대해 사용 권한이 있는지 확인/판별 |
| 방법 | 로그인, 생체인식 | session key, JWT, Oauth |

절차는 Authentication 이후에 Authorization 이 이루어진다고 보면 된다.

Authentication이 되었다고 해도 보내는 리퀘스트마다 이 사용자가 정말로 자격이 있는지 매번 확인을 하는 절차가 Authentication이라고 생각한다.

<br> 

## 스키마를 짤 때 하는 고민

이건 정말 광범위한 범위가 아닐까? 아직도 어떤 방식으로 스키마를 짜는 게 최적인지 잘 모르겠다. 정말 서비스마다 다른 것 같다. 내가 스키마를 짜면서 확실하게 느꼈던 부분은

1. 높은 수준의 정규화를 했을 때는 조회를 할 때 JOIN을 많이 해줘야 하지만 데이터 수정과 삭제가 용이하다.
2. 낮은 수준의 정규화를 했을 때는 조회할 때 JOIN을 많이 안 해줘도 된다. 그러나 중복된 데이터가 많아진다.
3. 히스토리 처럼 아래로 쌓이는 데이터의 경우 높은 수준의 정규화를 하지 않아도 된다.
4. 옛날에는 하드가 비싸서 정규화에 신경을 많이 썼는데 요즘은 하드가 비싸지 않아 정규화를 많이 할 필요가 없다고 한다.
5. UPDATE가 자주 일어나는 데이터인지 INSERT가 많이 일어나는 데이터인지에 따라서 스키마가 달라질 필요가 있다.

<br> 

## 고수준 인터페이스와 저수준 인터페이스

고수준 인터페이스와 저수준 인터페이스라는 단어보다는 고수준 모듈, 저수준 모듈을 더 많이 사용한다.  고수준 모듈은 추상화가 되어있는 기능을 제공하고 저수준 모듈은 고수준에서 제공하는 기능을 실제로 구현을 했다.

Java로 예를 들면 아래와 같을 것이다.  Animal 이란 고수준 모듈에서는 eat이라는 추상화된 기능을 제공하고, People 이라는 저수준 모듈이 Animal의 eat이 어떤 작업을 하는지 실제로 구현을 했다.

```java
// 고수준 
public interface Animal {
	void eat(); 
} 

// 저수준 
public People implements Animal {
	
	@Override 
	void eat() {
		Systems.out.println("People eat many things"); 
}
```

여태 고수준과 저수준을 반대로 생각하고 있던 게 아닐까 싶다. 고수준이 실제로 구현이 된 부분이고 저수준이 추상화의 부분인줄 알았다. 앞으로는 교수님을 생각하기로 했다. 수준이 높은, 고수준의 교수님들은 추상적으로 말을 하니까 고수준 모듈이 추상적이고, 그와 반대로 저수준 모듈이 구체적이다.
