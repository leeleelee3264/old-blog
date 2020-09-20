---
layout: post 
title: "[Spring] Mybatis Exception"
date: 2020-09-17
excerpt: "Thinking about how to handle Mybatis Exception."
tags: [index, absinthe4902]
feature: /assets/img/banff.png
comments: false
---
여기다가 쓸 내용 
0. Exception tree (나중)
1. checked exception vs unchecked exception (했음) 
2. sqlexception vs dataaccessexception 
3. actually dataacessexception is runtimeexception 
4. new mybatis sqlexeption sample code 
5. getcause rootcause 
6. 원래 남기는 로그 방법 
A week ago, I felt maybe I need to adjust exception of sql. At that time, I just used try-catch with Exception and print stacktrace for backend, passed some certain value to let front know something went wrong with request. I've never went deep down to Exception and how to handle, so let's first check what kind of Exception java has. 

# Exception hierarchy

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3997f024-4ec1-4f76-81b7-a5c66c7e7db6/checked_unchecked.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/3997f024-4ec1-4f76-81b7-a5c66c7e7db6/checked_unchecked.png)

Java use Throwable type when something goes wrong. The highest type Throwable then seperate to three pieces. Error, Checked Exception and Unchecked Exception. Error is just error. We cannot actually do something with error. It means, we don't have to (and can't) handle error. Then what about unchecked exception and checked exception? 

> Checked Exception at Compile time, Unchecked Exception at Run time.

## Checked Exception

If I want to run program, I have to compile code first. (Compiling is like translating. Translating human friendly language such as Java, C, Python to computer friendlt language which contains 0 and 1) If I make a mistake like opening not exsiting file, using not existing class or method then compiler will tell me 'Hey, this part is weird. I can't compile with these guys'. What should I do next? Without any choice, I must fix it. If not, I won't be able to run the program I made. Straight forwardly, checked exception will be checked by compiler at the very first time.

## Unchecked Exception

On the other hand, compiler can't catch unchcked excption which will happen in the future. And I also can't catch them either. I can olny predict and try to prevent code from exception with Exception handling. These are happend when program is actually running. We have certain rules about programming. Using legal argument, not accessing out of arrays, casting variable with proper  casting method, not using null as value etc. However, these kind of exception sometimes happends due to client passing wrong value, server using mistaken code ect. We shell see them after running program.  

And here is the point! Can you see SQLException under Exception tree? SQLException is one of checked exception. And it's today's topic. Now let's dig in to SQLException.

# SQLException and DataAccessException

I was a bit confused about the fact SQLException is checked exception. What I understand is that checked exception always pop up at compiler time. But in my ordinary code, exception related to sql pop up run time and compiler time both.
