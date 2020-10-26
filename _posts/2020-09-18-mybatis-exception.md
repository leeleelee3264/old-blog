---
layout: post 
title: "[Spring] Mybatis Exception"
date: 2020-09-18
excerpt: "Thinking about how to handle Mybatis Exception."
tags: [index, leeleelee3264]
feature: /assets/img/spring.png
comments: false
---

# [Spring] Mybatis Exception Handling

A week ago, I felt maybe I need to adjust exception of sql. At that time, I just used try-catch with Exception and print stacktrace for backend, passed some certain value to let front know something went wrong with request. I've never went deep down to Exception and how to handle, so let's first check what kind of Exception java has. 

# Exception hierarchy

![%5BSpring%5D%20Mybatis%20Exception%20Handling%20e0a1e27c763c4302bb70b3efb85274e1/checked_unchecked.png](/assets/img/post/checked_unchecked.png)

Java use Throwable type when something goes wrong. The highest type Throwable then seperate to three pieces. Error, Checked Exception and Unchecked Exception. Error is just error. We cannot actually do something with error. It means, we don't have to (and can't) handle error. Then what about unchecked exception and checked exception? 

> Checked Exception at Compile time, Unchecked Exception at Run time.

## Checked Exception

If I want to run program, I have to compile code first. (Compiling is like translating. Translating human friendly language such as Java, C, Python to computer friendlt language which contains 0 and 1) If I make a mistake like opening not exsiting file, using not existing class or method then compiler will tell me 'Hey, this part is weird. I can't compile with these guys'. What should I do next? Without any choice, I must fix it. If not, I won't be able to run the program I made. Straight forwardly, **checked exception will be checked by compiler at the very first time**.

## Unchecked Exception

On the other hand, compiler can't catch unchcked excption which will happen in the future. And I also can't catch them either. I can olny predict and try to prevent code from exception with Exception handling. **These are happend when program is actually running**. We have certain rules about programming. Using legal argument, not accessing out of arrays, casting variable with proper  casting method, not using null as value etc. However, these kind of exception sometimes happends due to client passing wrong value, server using mistaken code ect. We shell see them after running program.  

And here is the point! Can you see SQLException under Exception tree? SQLException is one of checked exception. And it's today's topic. Now let's dig in to SQLException.

# SQLException and DataAccessException

I was a bit confused about the fact SQLException is checked exception. What I understand is that checked exception always pop up at compiler time. But in my ordinary code, exception related to sql pop up run time and compiler time both. When I miss or don't configure setting about sql, compiler give me lots of error and stop right there. It were mostly about connection with spring and sql. On the other hand, If I made bad sql grammer or try to use unvalid value in sql sentence, then I got runtime exception. I didn't get value I'd expected, but program was still running. I did some research and found out there are **SQLException and DataAccessException** in spring. SQLException is checked exception and DataAccessException implements RuntimeException.

```java
org.springframework.dao
Class DataAccessException
java.lang.Object
	java.lang.Throwable
		java.lang.Exception
			java.lang.RuntimeException
				org.springframework.core.NestedRuntimeException
					org.springframework.dao.DataAccessException
```

> Change SQLException to DataAcessException

Now it's a trend to change checked exception to unchecked exception in standard spec and open source framework. Most of time, we can't react to checked exception right away. Because Java steped into server area, we have to go throght couple of step to fix exceptions. (coding, building, uploading, running...) People changed mind. If we can't fix exceptions fast, then at least we can make exceptions not too critical. Let's make checked exception to unchecked exception! It's bad hobby but sometimes we just ignore runtime exception and got ugly exception notification. I'll summarize it. 

- **turn checked exception to unchecked exception when caller (programmer) cannot fix, recover exception.**
- then what can I do with exception with sql? connection failure, bad sql grammer... obviously not many things.
- so let's just wrap it to unchecked exception to prevent stop running program.
- we still can use try-catch with runtime exception if we want.
- it even reduce writing throws and try-catch as well.

## reason of wrapping SQLException to DataAccessException

- only DAO has SQLException
- we should not pass sqlexception all the way throgh with bunch of throws.
- wrap SqlException to DataAccessException
- with DataAccessException, we can chose using exception handling when we really need.
- **it called abstraction of exception. make low level to high level.**
- with high level exception, we can get more detail about the occured exception.

# Finally! Exception code of Mybatis

When I wrote this code, it looked decent. But I feel like I have to change couple of things to improve. It's prototype anyway. Now the code's flow is very simple. Meeting exception, logging exception. I might need to handle indivisual case of exception later. At that moment, I'll use this code quite usfully. And for good measure, I seperate exception from mybatis and general concept of sql exception. Just in case. 

```java

/**
 * Created By Seungmin lee
 * User: ***
 * Date: 2020-09-15
 * Description: 각종 Exception 을 logging 하고 처리할 목적으로 만든 Util
 */
@Slf4j
public class ExceptionUtil {
    /**
     * mybatis 와 mysql에서 발생하는 error 들의 상세 logging 을 위한 메소드. 
     * 추후에 로깅뿐 아니라 예외처리 로직도 넣어둘 예정. 
     * @param ex MVC 단에서 던지는 예외 
     */
    public static void sqlException(Exception ex) {
        if (Objects.isNull(ex.getCause()) || Objects.isNull(ex.getMessage())) return;
        // Mybatis 라이브러리 내부에 어떤 오류둘이 있는지 몰라 일단 한 번에 처리 
        if(ex instanceof MyBatisSystemException) {
            log.error("**** Mybatis inner exception :{} ****",  ((MyBatisSystemException) ex).getRootCause().getMessage());
            return;
        }
        // TODO: DataAccessException 과 SQLException 은 같은 수준인데 Spring에서는 DataAcessException 이 더 제너럴해서 나중에 바꿀 수 있다. 
        SQLException higherEx;
        if (ex instanceof DataAccessException) {
            higherEx = (SQLException) ((DataAccessException) ex).getRootCause();
            log.error("**** DataAccessException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        }
        if (ex instanceof BadSqlGrammarException) {
            higherEx = (SQLException) ((BadSqlGrammarException) ex).getRootCause();
            log.error("**** BadSqlGrammarException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if(ex instanceof InvalidResultSetAccessException) {
            higherEx = (SQLException) ((InvalidResultSetAccessException) ex).getRootCause();
            log.error("**** InvalidResultSetAccessException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if(ex instanceof DuplicateKeyException) {
            higherEx = (SQLException) ((DuplicateKeyException) ex).getRootCause();
            log.error("**** DuplicateKeyException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if(ex instanceof DataIntegrityViolationException) {
            higherEx = (SQLException) ((DataIntegrityViolationException) ex).getRootCause();
            log.error("**** DataIntegrityViolationException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if(ex instanceof DataAccessResourceFailureException) {
            higherEx = (SQLException) ((DataAccessResourceFailureException) ex).getRootCause();
            log.error("**** DataAccessResourceFailureException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if(ex instanceof CannotAcquireLockException) {
            higherEx = (SQLException) ((CannotAcquireLockException) ex).getRootCause();
            log.error("**** CannotAcquireLockException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if (ex instanceof DeadlockLoserDataAccessException) {
            higherEx = (SQLException) ((DeadlockLoserDataAccessException) ex).getRootCause();
            log.error("**** DeadlockLoserDataAccessException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else if (ex instanceof CannotSerializeTransactionException) {
            higherEx = (SQLException) ((CannotSerializeTransactionException) ex).getRootCause();
            log.error("**** CannotSerializeTransactionException :{} // : {} ****", higherEx.getErrorCode(), higherEx.getMessage());
        } else {
            log.error("**** Exception :{} ****", ex.getMessage());
        }
    }
}
```

Things I have to fix

1. Stop using SQLException. Use DataAccessException instead. 
2. Do not use DataAccessException at the top of if statement. If is the lowest exception. 
3. Do I really need to print detailed logging? I could just print stack trace. It even has more info. 

# Reference

[RuntimeException and higher exception](https://docs.oracle.com/javase/8/docs/api/java/lang/RuntimeException.html?is-external=true)
[SQLException to DataAccessException](https://jongmin92.github.io/2018/04/04/Spring/toby-4/)
[Runtime and Compiletime](https://dd-corp.tistory.com/9)
[Spring SQLException Handling](https://webprogrammer.tistory.com/m/2448?category=149261)


