---
layout: post 
title: "[Linux] Host and url name convention"
date: 2021-01-13 22:)):59
author: Jamie Lee
categories: Backend
tags:	linux
cover:  "/assets/img/ubuntu.png"
pagination: 
  enabled: true
---

Today, I had to be through very awful exception. There is an api server I have to (my server have to) send a request to update  meta data. (For performance issue, this server just cached meta data and uses it till updated)
Usually it's quite simple. Make request with RestTemplate (currently I'm using spring boot) and send, bring response to client. 
This situation got started two days age. The server which contains api server moved to new ec2 machine and it had new ip. So I have to send my request to the new ip. 
I had wrote a previous ip on application.properties. Just like this. 
```yaml
api.server.domain=http://172.22.32.1:8000
```
Let's say the new ip is 180.1.1.1:8000. I could just change api.server.domain to http://180.1.1.1:8000, but it's so annoying I have to change application.properties file and rebuild, re-deploy server every time when ip gets changed.
I thought now is the perfect timing to use `/etc/hosts` file in Linux. 

## what is /etc/hosts file? 
Domain is kine of alias of ip. In other words, every domains have its own ip. When we type domain to go to specific site, before this request goes any farther it goes to DNS server to get a real ip of the domain. 
`/etc/hosts` are local, tiny version of DNS for own ubuntu machine. Ubuntu usually goes check `/etc/hosts` first and goes to DNS. The file used to work like back up DNS long time age to prevent DNS error. 
Nowadays the file use to find host name which is not registered in DNS. For example, localhost. There is not real domain named localhost, it's just living in `/etc/hosts`

```yaml
# /etc/hosts
127.0.0.1 localhost
```
Like localhost, I wanted to make own host name for this inner server. These were what I did. 

```yaml
# /etc/hosts in Linux  
127.0.0.1 api_call_server

# application.properties in Spring boot 
api.server.domain=http://api_call_server 

# code in Spring boot and I use RestTemplate to send a request
@Value("${api.server.domain}")
private String serverDomain
```

But it turned out I did something wrong. I kept getting 400 Bad request from api server. You may get `unknown host exception` when you send a request to a host which is not in /etc/hosts file. But I already added! 
On my second thought, maybe the reason for the exception is DNS caching. But it was not that. 

## Reason for the  



# 로컬호스트처럼 아이피 등록해서 쓰려소 했다 
# 근데 계속  400 에러가 나더라 
# 알고보니 hostname에 허용되지 않은 _ 을 써서 그랬다. 
https://stackoverflow.com/questions/1133424/what-are-the-valid-characters-that-can-show-up-in-a-url-host
# 한 김에 url convention 도 
# 어지간하면 allowed 하고 safe 한 것만 쓰자. unsafe 랑 system 적으로 reserved 된거 말고 
https://stackoverflow.com/questions/695438/what-are-the-safe-characters-for-making-urls
