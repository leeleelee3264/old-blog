---
layout: post 
title: "[Java] Regex cheat sheet for myself"
date: 2021-01-11 20:43:59
author: Jamie Lee
categories: Backend
tags:	Regex
cover:  "/assets/img/Java_logo_icon.png"
pagination: 
  enabled: true
---

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
