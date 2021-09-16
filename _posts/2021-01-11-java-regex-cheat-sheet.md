---
layout: post 
title: "[Java] Regex cheat sheet for myself"
date: 2020-09-24 08:43:59
author: Jamie Lee
categories: Cheat
tags:	Regex
cover:  "/assets/img/Java_logo_icon.png"
pagination: 
  enabled: true
---

# plain 숫자 스트링을 전화번호 형식으로 바꾸기 

```java
 public static void testNumber(String src) {

        Pattern SRC_PHONE_FORMAT =  Pattern.compile("(\\d{3})(\\d{4})(\\d{4})");
        Pattern DEST_PHONE_FORMAT = Pattern.compile("$1-$2-$3");

        String dest = src.replaceFirst(SRC_PHONE_FORMAT.toString(), DEST_PHONE_FORMAT.toString());
        System.out.println(dest);
    }
```
<br> 
보통 정규식으로는 내가 원하는 형태로 값이 들어왔나 체크하느라 쓰는 경우가 많았고, 값을 바꾸는데 정규식을 이용한적이 드물어서 처음에 어떻게 해야 하나 
많이 헷갈렸는데 방법을 찾았다. 맨처음에는 패턴들에 통째로 replaceAll을 걸었는데 그럼 결과가 그냥 DEST_PHONE_FORMAT.toString()이랑 동일한 결과가 나온다. 
replaceFirst를 걸어서 ()()() 이렇게 끊어서 하나씩 적용을 시켜주면 된다. 원래 regex group으로 값들을 꺼내서 바꿀까 했는데 어쨌든 비슷한 느낌이다. 

<br> 
<br> 

# Extracting SubString 

> case 1: Extracting before and after of specific character
<br>

Let's say I get string with static prefix and I only need string after the prefix. For example, "A:COME_IN". "A" is prefix and I only need "COME_IN". 
I could guess prefix is only one character, however it wouldn't be general to many case. So I will set wild care before and after of the prefix.

```java
String src = "A:COME_IN"; 

Pattern pattern = Pattern.compile("([^,]*):([^,]*)");
Matcher mater = pattern.matcher(src);

if(mater.find()) {
        String before = mater.group(1); // "A"
        String after = mater.group(1); // "COME_IN"
    }
```
I usually don't make matcher. I just go for `pattern.matcher(src).matches` because in that case I don't have to return a string. All I have to do is 
checking (1) specific character is in the string, (2) the string is suited for format. 
But in this case, I have to return sub string. 

1. I have to use find() method to move forward. It works like iterator hasNext(). It keeps moving after checking a part of the src string. (Finding makes matcher keep moving forward)
2. group(0) return whole chosen string if src matches pattern. group(1) is 'A', group(2) is 'COME_IN'


<br> 

> case 2: Extracting between special characters
Think about string like this. 'I (Love) you' and let's say I want to extract Love. This will teach me how to do this. 

```java
Pattern pattern = Pattern.compile("\\((.*?)\\)");
        Matcher matcher = pattern.matcher(src);

        if(matcher.find()) {
            System.out.println(matcher.group(0)); // (Love)
            System.out.println(matcher.group(1)); // Love
        }
```

'\\' (twice of \) is escape for '(' and ')'. It is well known fact that some characters can cause confusion to computer, so it's like safety lock for those kind of letters. 
Leave the link about group for later. I think I'll confused by the concept again [what is group in java regex](https://www.tutorialspoint.com/javaregex/javaregex_capturing_groups.htm)
