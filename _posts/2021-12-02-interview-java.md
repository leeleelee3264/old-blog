---
layout: post
title: "[Interview] 2021 Backend Engineer Interview - Java"
date: 2021-12-02 08:43:59
author: Jamie Lee
categories: General
tags:	sql
pagination:
enabled: true
---

<br> 

> 2021 하반기 기술면접에서 나온 질문들과 소감을 정리한 포스팅입니다.
>

index

1. Intro
2. 기술면접 회고
3. Java
  1. Spring Boot reload changed properties on running
  2. JDBC
  3. 자바 직렬화
  4. Interface와 abstract의 차이
  5. DI, IOC
  6. static

---

# Intro

---

10월 달 부터 이직을 준비하기 시작하며 Resume 와 Cover Letter 를 썼고, 11월 달에는 면접을 보러 다녔다. 대부분의 면접들이 몇 단계로 이루어져있었는데 기술 면접에서 면접관들이 물어봤던 질문들을 기록해두고 공유하면 좋을 것 같아 포스팅을 하기로 했다.

지원분야가 Backend이기 때문에 대부분의 질문들이 Backend 와 관련이 되어있지만, 직전에 근무하고 있던 회사에서 DevOps의 경험도 있다고 이력서에 적어서 DevOps와 관련된 질문들도 약간 있었다. 깃허브에 DevOps 커리큘럼이 올라와있어 공유를 한다. 날을 잡고 제대로 읽어보면 많은 도움이 될 것 같다.

[https://github.com/Knowre-Dev/DevOpsCurriculum](https://github.com/Knowre-Dev/DevOpsCurriculum)

---

# 기술면접 회고

---

커리어를 시작하고 이렇다 할 면접들을 보러 다닌적이 없었는데 기술면접을 보고 나니 왜 공부를 더 열심히 해야 하는지 깨달았다. 이론적인 측면들은 지루해서 공부를 피하기 마련이었는데 기술면접에서 다 물어보는 것들이었고, 결국은 이 이론적인 측면들을 잘 알아야지만 더 좋은 코드를 만들 수 있다.

파이썬을 그냥 써보기만 했고 깊이가 없었다. 다른 개념들도 마찬가지였다. 막 커리어를 시작했을 때는 이것저것 조금씩 공부하는 게 좋았는데 이제는 깊이가 있는 공부를 해야하는 때가 아닌가 싶다.

퇴사를 준비하면서 이것저것 많이 여쭤봤던 팀장님께 인사를 드렸는데 기술에 대한 욕심을 조금 버리는 게 좋다고 조언해주셨다. 그도 그럴게 2년 동안 정말 신기술에 집착을 많이 했던 것 같다... 그 분이 항상 해주시던 말씀이 프레임워크를 공부하기보다는 언어를 더 공부하라 였는데 결국 기본기가 제일 중요한 게 아닐까? 디자인 패턴과 정규식은 어디에서도 쓰이는 것처럼.

빨리 사둔 디자인 패턴 책도 읽고 이팩티브 자바도 다시 읽어봐야겠다. 자바 빨리빨리 공부하고 파이썬으로 진짜 넘어가야지!

---

# Java 질문

---

이력서에 주로 사용하던 언어가 자바라고 썼기 때문에 자바 질문이 들어왔고 면접을 본 회사들은 대부분 파이썬을 사용하고 있었기 때문에 파이썬 질문도 많았다. 질문의 구성은 크게 아래와 같았다.

1. 자바 질문
2. 파이썬 질문
3. 개발 전반 상식

이번 포스팅에서는 자바 질문과 답변을 다룬다.

## Spring Boot reload changed properties on running

---

맨 처음에는 Spring boot에서 properties 를 적용하는 방법에 대한 질문인 줄 알고 Spring boot externalized properties 우선순위에 대해 답변했는데 아니었다. 이미 러닝중인 서버에 수정된 propreties를 재시작없이 어떻게 반영하냐에 대한 질문이었다.

이는 Spring Boot Actuator 를 이용하면 된다. 이렇게 config 를 러닝 타임에 업데이트 하는 상황은 서버가 하나 떠있을 때 보다는 서버를 여러 개 띄워두는 Spring Cloud 환경에서 많이 사용하는 것으로 보인다. Spring Cloud Config는 Spring Cloud Config 서버와 클라이언트 어플리케이션 (그림에서 Microservice #1 #2 #3 로 표기된 서버들) 로 구성이 되어있는데 **config 서버 설정에 변경이 생겼을 때 클라이언트 어플리케이션도 변경을 반영해줘야 한다. 이때 다시 시작하지 않고 actuator 를 이용해서 refresh 하면 된다.**

여기서 actuator 는 실행중인 스프링 어플리케이션 내부 정보를 REST 엔드포인트와 JMX MBeans(Java Management Extension. 모니터링용 객체) 로 노출시키는 스프링 부트의 확장모듈이다. 실행중인 스프링 어플리케이션을 뜯어 볼 수 있다는 게 중요하다!

1. 클라이언트 어플리케이션에 actuator 라이브러리를 implement 한다.
2. 클라이언트 어플리케이션 [application.properties](http://application.properties) 또는 application.yml 에 actuator 사용을 위한 설정 추가
3. Config 서버에서 가져온 설정을 사용하는 코드 부분에 @RefreshScope 추가
4. [http://클라이언트서버url](http://클라이언트서버url)/actuator/refresh post 호출로 변경사항 적용

![Untitled](/assets/img/post/cloud.png)

자세한 예제는 아래의 링크들에서 확인할 수 있다.

[Spring cloud config 리프래시 하기 (Use RefreshScope)](https://elfinlas.github.io/2019/06/25/spring-config-refresh/)

[Spring Cloud Config 2](https://multifrontgarden.tistory.com/237)

## JDBC

---

Java Database Connectivity.  데이터베이스 연결을 관리하는 자바 API로, 쿼리와 커맨드를 발행하고 데이터베이스에서 건내주는 결과 셋을 처리한다. JDBC는 자바 어플리케이션이 데이터베이스 또는 RDBMS와 소통하기 위한 프로그래밍 레벨 인터페이스를 제공한다.

결과적으로 자바 코드로 데이터베이스를 관리할 수 있게 만들어준다.

![Untitled](/assets/img/post/jdbc.png)

1. JDBC API는 자바 어플리케이션과 JDBC Manager 사이의 커뮤니케이션을 지원한다.
2. JDBC Driver는 데이터베이스와 JDBC Manager 사이의 커뮤니케이션을 지원한다.

## 자바 직렬화 **Serialize**

---

직렬화는 객체를 바이트 스트림으로 바꾸는 것이다. 이와 반대로 바이트 스트림을 객체로 바꾸는 것은 역직렬화라고 한다. 객체는 플랫폼에서 독립적이지 못하다. 그래서 파일, 메모리, 데이터베이스 처럼 다른 시스템으로 보내려고 할 때 플랫폼에서 독립적인 바이트 스트림으로 변환을 한다.

![Untitled](/assets/img/post/seri.png)



자바 직렬화도 마찬가지로 JVM 메모리에 올라가있는 객체를 byte 스트림 (byte 형태의 데이터) 바꾸는 것이다. 그런데 요즘의 API들을 생각해보면 데이터를 다 JSON으로 직렬화 해서 내보내고 있다.  JSON 처럼 문자열로 변환하는 형태가 아니라 이진 표현으로 변환해서 내보낼때는 Protocol Buffer를 사용한다고 한다. 그럼 손쉬운 JSON과 Protocol Buffer가 아니라 번거로운 자바 직렬화를 사용해야 할 때는 언제일까?

자바 직렬화의 장점은 자바에 최적화 되었다는 점이다.  자바 시스템에서 또 다른 자바 시스템으로 데이터를 보낼 때 손쉽게 직렬화-역직렬화를 할 수 있다. 서블릿 세션이 대표적인 사용처라고 하는데 홈페이지를 만들때도 유저의 로그인 세션을 직렬화해서 관리했던 게 생각이 난다.

![Untitled](/assets/img/post/jseri.png)


이팩티브 자바에도 나와있지만 다들 입을 모아 자바 직렬화는 추후에 발생할 문제를 많이 품고 있다고 한다.

1. 직렬화-역직렬화를 할 때 타입과 필드의 변경에 엄격해 오류가 잘 발생할 수 있다.
2. 때문에 자주 변경되는 클래스는 자바 직렬화를 사용하지 않는 것이 좋다.
3. 외부에 나가서 장기 보관될 정보는 자바 직렬화를 사용하지 않는다. 추후에 변경이 있으면 오류가 나기 때문에.
4. 자바 직렬화에 사용하는 시리얼 ID도 개발시에 따로 관리를 해줘야 한다.
5. 자바 직렬화된 데이터는 JSON 보다 훨씬 크기가 크다. 떄문에 직렬화된 데이터를 캐시등의 이유로 존재하는 Redis 와 같은 메모리 서버에 저장을 하면 트래픽에 따라 비용이 급증할 수 있다.
6. 위와 같은 이유들로 최대한 JSON 포맷으로 변경을 고려해야 한다.

저번에 FCM으로 보낼 푸시 메세지들을 직렬화해서 Redis 메모리에 넣어두어 어플리케이션 서버에서 큐 구조로 순차적으로 꺼내갈 수 있게 해뒀는데 이번에 직렬화를 찾아보니 JSON으로 바꾸는 방향으로 해야겠다..

[자바 직렬화, 그것이 알고싶다. 훑어보기편 | 우아한형제들 기술블로그](https://techblog.woowahan.com/2550/)

## Interface와 abstract의 차이

---

추상클래스는 A is B를 만족시킨다.  추상메서드를 만들 수 있고, 구현이 된 메서드를 만들 수 도 있다. 일반 클래스와 마찬가지로 필드도 가질 수 있다.

인터페이스는 A is able to B 를 만족시킨다. 인터페이스는 자바8, 9에 들어오면서 원래의 인터페이스에서 많은 변화가 생겼다.

- 추상메서드만 만들 수 있었으나 JAVA 8에 들어오면서 default를 사용해 메서드 구현이 가능해졌다.
- 필드를 가질 수 없었으나 JAVA 8에 들어오면서 final 과 static 필드를 가질 수 있게 되었다.
- 접근 지정자가 default로 private 이었으나 JAVA 9에 들어오면서 private 사용도 가능해졌다.

추상 클래스와 인터페이스 모두 선언만 가능하고, new 를 사용해서 인스턴스를 만드는 게 불가능하다. 실무에서 추상클래스를 사용했는데 상속관계를 제대로 고려하지 않았었기 때문에 모두 리팩토링을 해야 했다. 추상클래스를 사용을 할 때에는 super 클래스와 하위클래스의 관계를 잘 생각해서 구현을 해야 하고, 추상클래스 보다는 인터페이스 사용을 권장한다.

## DI, IOC

---

Dependency Injection과 Inversion Of Control. Spring에서 처음 접한 개념인데, Spring 뿐만 아니라 다른 언어와 프레임워크에서도 널리 사용되는 개념이다. **IoC는 설계 원칙이고 DI 는 IoC 원칙을 지키기 위한 디자인 패턴이다.**  실제로 DI 말고도 IoC를 위한 다양한 패턴이 존재한다.

![Untitled](/assets/img/post/ioc.png)

IoC는 객체 사이의 결합도를 줄이기 위해 제어를 역전시킨다. 가장 흔한 제어의 역전의 예시로는 객체 생성이 있다. 제어 역전이 일어나면 객체를 직접 생성하지 않고, 이미 생성되어 있는 코드를 사용하기만 한다. Spring으로 예를 들어보면 Bean으로 선언된 객체들은 Spring에서 관리를 한다. Bean 객체들은 IoC Container 안에 생성이 되고, 관리가 된다. 우리는 그 객체들이 어떻게 관리가 되고 있는지 알 필요 없이 해당 객체를 사용해야 할 때 의존성을 주입받아 (DI) 사용을 하면 된다.

```java
@Controller 
public class TestController {

	private final TestService testService; 

	public TestController(TestService testService) {
		this.testService = testService; 
	}

}
```

DI는 의존성 있는 객체의 생성을 class 외부에서 수행한 후, 다양한 방법으로 해당 객체를 class 에게 제공한다. DI을 이용해 객체 결합도를 느슨하게 하기 위해서는 Client, Service, Injector 클래스가 필요하다. Injector 클래스가 Service 객체를 만들어 Client 클래스에 제공하는 형태인데 코딩을 하면서 무수히 많은 객체들의 의존성을 매번 이렇게 만들어 줄 수는 없다. 때문에 IoC Container와 같은 기능을 제공하는 프레임워크를 사용해 위와 같은 일을 위임한다.
프레임워크를 사용하면 객체의 의존도를 고려하면서 객체의 생성. 소멸을 신경쓰지 않아도 되고 비즈니스 코드에 더 집중을 할 수 있고 결과적으로 변경에 유연한 코드를 만들 수 있다. 

면접 질문이라 간단히 정리를 했지만, 아래 포스팅에서 코드와 함께 IoC와 DI에 대해서 더 자세하게 볼 수 있다.



[Dependency Injection, IoC, DIP, IoC container정리](https://medium.com/sjk5766/dependency-injection-ioc-dip-ioc-container%EC%A0%95%EB%A6%AC-310885cca412)

## static

---



static 키워드를 사용한 메서드와 변수는 해당 클래스의 객체를 생성하지 않아도 해당 메서드와 변수를 사용할 수 있다. 매번 객체를 생성하지 않아도 되기 때문에 손쉽게 사용을 할 수 있어 내 경우는 Utill 성 메서드들을 static으로 만들었다.

static은 메모리에 딱 한 번 할당이 된다. 일반적인 객체들이 Heap 영역에 할당이 되는 것과는 다르게 stack 영역에 만들어진다. 때문에 Heap 처럼 Garbage Collection을 걱정하지 않아도 되며, stack 은 모든 객체가 공유하는 메모리 공간이기 때문에 객체 생성이 없이도 static 메서드와 변수를 사용할 수 있다. Java 8이전에 static 변수와 메서드는 JVM  메모리에서 PermGen에 저장이 되었으나 Java 8에서는 PermGen 가 사라지고 MetaSpace가 그 역할을 대신한다. 변경된 Java 8 JVM 구조는 아래와 같다.

![Untitled](/assets/img/post/jvm.png)

면접을 보고 나와서 static에 대해서 조금 더 찾아봤다. static의 핵심 구현 사항은 아래와 같다.

> 인스턴스 변수 (non-static) 를 사용하는 메서드는 인스턴스 메서드를 사용하고 클래스 변수 (static) 을 사용하는 메서드는 static 메서드를 사용한다.
>

1. 클래스를 설계할 때 인스턴스에 공통적으로 사용해야 하는 맴버변수에 static을 사용한다.
2. static 메서드에서는 static이 아닌 맴버변수는 사용할 수 없다.
3. static 이 아닌 메서드에서는 static인 맴버변수를 사용할 수 있다.
4. 메서드 안에서 인스턴스 변수를 사용하지 않는다면 static을 사용을 고려한다.

1과 같은 특성으로 한 인스턴스에서 static 변수의 값을 바꿨을 때 모든 인스턴스에 변경이 적용된다. 이와 같은 모두 변경 불상사를 피하기 위해서 static 변수를 사용할 때 final 키위드를 함께 사용해 변경을 불가하게 만든다.

2, 3과 같은 일이 일어나는 이유는 인스턴스 변수가 static 변수 또는 메서드를 사용하는 시점에서는 static 변수와 메서드가 이미 생성이 되어있지만 반대의 경우에는 사용 시점에 인스턴스가 만들어졌는지 알 수 없기 때문이다.
