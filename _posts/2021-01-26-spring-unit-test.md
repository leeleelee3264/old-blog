---
layout: post 
title: "[Spring] Spring boot unit test with Junit5"
date: 2021-01-26 22:00:59
author: Jamie Lee
categories: Backend
tags:	spring
cover:  "/assets/img/ubuntu.png"
pagination: 
  enabled: true
---

> I know I have to do unit test ...

Making test code is always big burden for me. No time for writing test code, and also don't know how. What is @SpringBootTest and Junit??  
I always felt something like that when thinking about test, but I do think I have to study it and I'll do it today.  The main point of making `test code is be unit!` Do not test whole flow! (TBH I've usually done that because of web page).
I thought test with spring boot test code is so heavy that I have to wait for server reload a lot. And now I know it happened because I tried to test the whole program. It indeed just like the server I had written right before the test. My bad.  

There are three parts of testing code. I'll cover step-by-step. I got a lot of help from this document! Should check before working with test code. [Testing Spring Boot](https://www.baeldung.com/spring-boot-testing)

1. Repository (JPA) test
2. Service test
3. Controller test 

> Basic libs for test in spring boot
```yaml
 testImplementation('org.springframework.boot:spring-boot-starter-test') {
        exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
    }

 testCompile group: 'org.junit.jupiter', name: 'junit-jupiter-api', version: '5.7.0'
```

I had no idea how people use `assertThat`, because I only got `assert`. It turned out that I have to install additional lib `junit`. I thought all the test function was built in `spring-boot-starter-test`. Silly me. 
There are so many options of test function include assertThat and assert. I'm quite sure I do have to check as soon as possible to handle junit test 100%. Junit test function doc is here [Junit test function](https://junit.org/junit5/docs/snapshot/user-guide/index.html)


## Repository test 

> original code UserRepository.java
```java
@Repository
public interface UsersRepository extends JpaRepository<UsersVO, Long> {

    List<UsersVO> findByName(String name);

    List<UsersVO> findByNameLike(String name);

    /**
     * jpa update 는 분명 모든 것을 한 큐에 업데이트 하는 그런.. 성격인가봄
     * @param id
     * @param name
     */
    @Modifying
    @Query("update users u " +
            "set u.name = :name " +
            "where u.id = :id")
    void updateName(@Param(value = "id") long id, @Param(value = "name") String name);
}
```

> test code UserRepositoryTest.java
```java
@ExtendWith(SpringExtension.class)
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
public class UsersRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UsersRepository usersRepository;

    @Test
    public void whenSave_thenReturnUsers() {
        UsersVO jpaEntity = UsersVO.builder()
                .name("tryNoDB")
                .salary(20000)
                .build();

        entityManager.persist(jpaEntity);
        entityManager.flush();

        UsersVO saved = usersRepository.save(jpaEntity);
        assertThat(saved.getName()).isEqualTo(jpaEntity.getName());
    }

    @Test
    public void should_update_name_by_id() {
        long id = 2;
        String name = "Jamie";
        String notName = "rer";

        // entityManager 은 진짜 jpa 에 있는 entity 를 위한거다.
        // jpa entity 가 아니면 못 쓴다는 소리임임
//       entityManager.persist(id);
//        entityManager.flush();;

        usersRepository.updateName(id, name);
        List<UsersVO> updated = usersRepository.findByName(name);

        assertThat(updated.get(0).getName()).isEqualTo(notName);
    }
}
```
- I saw `@RunWith(SpringRunner.class)` a lot on internet, it made a connection between spring boot and junit during test. It's for junit 4. For junit 5, it should be `@ExtendWith(SpringExtension.class)`.
- `@DataJpaTest` anno is building test env for database. It configured in memory H2 db to divide our real db during the test. 
- With newly configured H2 db honestly not have data. So we put our sample data before running test. `TestEntityManager` does this job for us.

I'm a very beginner of JPA. I quite know nothing about JPA, but I know persistence is great deal in JPA. To keep this policy we should use EntityManager. (I guess it's something like cache before commit to real db)
And I have so many experience updating our real db record during test. The change didn't go back either. Now I think I know why. I have to use `@DataJpaTest` to make fake env for db testing. 
I even tried to put HashMap in EntityManager. Keep in mind it only takes `@Entity` object. 
This doc is pretty intense. I guess there are so many test code for Jpa function, should take a look [JPA test doc](https://bezkoder.com/spring-boot-unit-test-jpa-repo-datajpatest/)
<br>

## Service test

> original code 

