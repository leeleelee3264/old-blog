---
layout: post 
title: "[Spring] Spring boot unit test with Junit5"
date: 2021-01-26 22:00:59
author: Jamie Lee
categories: Backend
tags:	spring
cover:  "/assets/img/spring.png"
pagination: 
  enabled: true
---

> I know I have to do unit test ...

Making test code is always big burden for me. No time for writing test code, and also don't know how. What is @SpringBootTest and Junit??  
<br>
I always felt something like that when thinking about test, but I do think I have to study it and I'll do it today.  The main point of making `test code is be unit!` Do not test whole flow! (TBH I've usually done that because of web page).
I thought test with spring boot test code is so heavy that I have to wait for server reload a lot. And now I know it happened because I tried to test the whole program. It indeed just like the server I had written right before the test. My bad.  

There are three parts of testing code. I'll cover step-by-step. I got a lot of help from this document! Should check before working with test code. [[Testing Spring Boot]](https://www.baeldung.com/spring-boot-testing)

1. Repository (JPA) test
2. Service test
3. Controller test 

> Basic libs for test in spring boot     
<br>
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
<br>
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
<br>
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
<br>
I'm a very beginner of JPA. I quite know nothing about JPA, but I know persistence is great deal in JPA. To keep this policy we should use EntityManager. (I guess it's something like cache before commit to real db)
And I have so many experience updating our real db record during test. The change didn't go back either. Now I think I know why. I have to use `@DataJpaTest` to make fake env for db testing. 
I even tried to put HashMap in EntityManager. Keep in mind it only takes `@Entity` object. 
<br>
This doc is pretty intense. I guess there are so many test code for Jpa function, should take a look [[JPA test doc]](https://bezkoder.com/spring-boot-unit-test-jpa-repo-datajpatest/)
<br>

## Service test

> original code UsersService.java
<br>

```java
public interface UsersService {

    List<UsersVO> findByName(String name);
    List<UsersVO> findByNameLike(String name);
    UsersVO save(UsersVO vo);
}

```
<br>
```java
@Slf4j
@Service
public class UsersServiceImp implements UsersService {

    @Autowired
    private UsersRepository usersRepository;

    @Override
    public List<UsersVO> findByName(String name) {
        try {
            return usersRepository.findByName(name);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return Collections.emptyList();
        }
    }

    @Override
    public List<UsersVO> findByNameLike(String name) {
        try {
            return usersRepository.findByNameLike(name);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return Collections.emptyList();
        }
    }

    @Override
    public UsersVO save(UsersVO vo) {
        usersRepository.save(vo);
        return vo;
    }
}
```
<br>
> test code UsersServiceTest.java
```java
@ExtendWith(SpringExtension.class)
class UsersServiceImpTest {

    // 일단 test code 에서 autowired 하는데 필요한 형식이다
    @TestConfiguration
    static class UsersServiceTestConfiguration {

        @Bean
        public UsersService usersService() {
            return new UsersServiceImp();
        }
    }

    @Autowired
    UsersService UsersService;

    // 이렇게 mock 으로 해두면 진짜 리포지토리 부르는 걸 우회한다.
    @MockBean
    private UsersRepository usersRepository;

    @BeforeEach
    public void setUp() {
        UsersVO test = UsersVO.builder()
                .name("test_account")
                .salary(1000)
                .build();

        Mockito.when(usersRepository.findByName(test.getName()))
                .thenReturn(Collections.singletonList(test));
    }

    @Test
    public void whenValidName_thenUsersShouldBeFound() {
        String name = "test_account";
        List<UsersVO> found = UsersService.findByName(name);

        assertThat(found.get(0).getName()).isEqualTo(name);
    }

    @Test
    void whenSaved_thenUsersShouldBeReturned() {
        UsersVO test = UsersVO.builder()
                .name("dummy_account")
                .salary(1000)
                .build();

        UsersVO saved = UsersService.save(test);

        assertThat(saved.getName()).isEqualTo(test.getName());
    }
}
```
<br>
Service layer depends on Repository (aka persistence layer) but in test, service layer don't have to know how it works. 
It means we have to make full service test code without wiring repository and we can do it with 'Mocking' function. It literally mock repository. 
<br>
> what is @TestConfiguration? 
At first, I couldn't understand why I use the annotation. UsersServiceImp is already made as @Bean and official doc told me the annotation is used to wire UsersServiceImp and work like bean. 
It's because UserServiceImp is implementation. In normal situation, our smart spring will load UsersServiceImp even though we wrote UsersService but it's not working in the test, so we have to do it manually. 
@TestConfiguration help the test to do this process. 
<br>

> what is @MockBean?
<br>
In test env, everything is independent. We have to test service without real repository unless we test both of them. @MockBean help to make fake, mocked repository for service. 
It's mocked so basically it's not connected with the real db and it means we have no data. In setUp() method, we have to make homemade preparation. Set up Mocked data and even make mock repository action there. 
It seems quite not helpful in this case, but with many lines of service code, we do want to know the code work (without repository). It's unit test after all. 

<br>


## Controller test 
Controller test code is just like Service test code. Don't have to know nor test service, only focus on controller part. 

> original code ApiController.java

<br>
```java
@Slf4j
@Controller
@RequestMapping("/api")
public class ApiController {

    private final UsersServiceImp usersServiceImp;

    public ApiController(UsersServiceImp usersServiceImp) {
        this.usersServiceImp = usersServiceImp;
    }

    @PostMapping("/bean/valid")
    @ResponseBody
    public ResponseEntity beanValid(@Valid @RequestBody MessageDTO messageDTO) {
        String value = messageDTO.getMessage();
        return new ResponseEntity<>("Your request is accepted!", HttpStatus.OK);
    }

    @GetMapping("/jpa/get")
    public String getByJpa(
            @RequestParam @Nullable String name,
            Model model
    ) {
        List<UsersVO> users =  usersServiceImp.findByName(name);

        model.addAttribute("userList", users);
        return "mockTest";
    }

    @PostMapping("/jpa/save")
    @ResponseBody
    public ResponseEntity saveByJpa(
        @Valid @RequestBody UsersVO usersVO
    ) {
        UsersVO result = usersServiceImp.save(usersVO);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }
}
```

<br>

> test code ApiControllerTest.java 
<br>
```java
// @SpringBootTest 이 어노테이션을 쓰면 통합 테스트가 된다. unit 테스트에서 지향해야 함. 그리고 이건 실제 db 가 엑세스가 된다.
@ExtendWith(SpringExtension.class)
// 이 어노가 있으면 마치 ApiController 만 있는 것처럼 스프링 부트를 제한해준다.
@WebMvcTest(ApiController.class)
class ApiControllerTest {

    // 얘가 바로 full http server 시작 안 하고 controller 테스트 할 수 있게 해주는 것!
    @Autowired
    private MockMvc mvc;

    @MockBean
    private UsersServiceImp usersServiceImp;

    @Autowired
    protected ObjectMapper objectMapper;

    protected String asJsonString(final Object object) throws JsonProcessingException {
        return objectMapper.writeValueAsString(object);
    }

    @Test
    public void givenUsersVO_whenGetUsersVO_thenReturnPOJO() throws Exception {

        UsersVO dummy = UsersVO.builder()
                .name("jamie")
                .salary(1000)
                .build();

        given(usersServiceImp.save(dummy)).willReturn(dummy);

        mvc.perform(post("/api/jpa/save")
                .content(asJsonString(dummy))
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name", is(dummy.getName())));

    }

}
```

`@WebMvcTest` anno will make MVC infrastructure to our test condition and you see, we wrote ApiController.class in the anno.
It makes spring boot server which only has ApiController. Pretty awesome haha. Furthermore, MockMvc provide super easy controller test env without loading full HTTP server. (light and fast!)
Leave `@SpringBootTest` for integration test aka test everything! It doesn't make mock bean, so it will do read and write your db. You should be aware this.
<br>

<hr>
<hr>
And in addition, I already made integration test using @SpringBootTest
It did not make any mock bean so that it always access real db. In this code, I can check GET page answer too. 

> Integration testing code.  
<br>
```java
public class ApiControllerTestNotUnit extends ControllerTestFrame {

    @Autowired
    private ApiController apiController;

    @Override
    protected Object controller() {
        return apiController;
    }

    /**
     *  mvc test with post param POJO
     * @throws Exception
     */
    @Test
    public void beanValid() throws Exception {

        MessageDTO user = new MessageDTO(1, "", "434", "r3r3r");

        jsonMock.perform(post("/api/bean/valid")
            .contentType(MediaType.APPLICATION_JSON)
            .content(asJsonString(user)));
    }

    /**
     * test get page with param
     * 이 형태는 아무래도 실제로 spring application 을 띄운게 아니라서 modelandview 정보만 찍어주고 실제는 파악이 힘든 듯
     */
    @Test
    public void getByJpa() throws Exception {

        MultiValueMap<String, String> param = new LinkedMultiValueMap<>();
        param.add("name", "Sam");

        jsonMock.perform(get("/api/jpa/get").params(param))
                .andExpect(view().name("mockTest"))
                .andDo(MockMvcResultHandlers.print())
                .andReturn();

    }

    /**
     * 이래 놓으면 실제로 db에 저장이 되어버린다. 망함.. 방법은 db 분리하기다. 선택에 따라서 test 환경에서는 h2 같은 db를 쓸 수 잆다고 함
     * @throws Exception
     */
    @Test
    public void saveByJpa() throws Exception {

        UsersVO jpaEntity = UsersVO.builder()
                .name("noinDB")
                .salary(2000)
                .build();

        jsonMock.perform(post("/api/jpa/save")
                .contentType(MediaType.APPLICATION_JSON)
                .content(asJsonString(jpaEntity)));
    }

}
```
<br>
> ControllerTestFrame.class
<br>
```java
@SpringBootTest
@AutoConfigureMockMvc
public abstract class ControllerTestFrame {

    protected MockMvc jsonMock;

    @Autowired
    protected ObjectMapper objectMapper;

    abstract protected Object controller();

    protected String asJsonString(final Object object) throws JsonProcessingException {
        return objectMapper.writeValueAsString(object);
    }

    @BeforeEach
    private void setup() {
        jsonMock = MockMvcBuilders.standaloneSetup(controller())
                // to bind exception with mockMvc
                .setControllerAdvice(new MyExceptionHandler())
                .addFilter(new CharacterEncodingFilter(StandardCharsets.UTF_8.name(), true))
                .alwaysDo(print())
                .build();

    }

}
```
