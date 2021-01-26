---
layout: post 
title: "[Linux] Host and url name convention"
date: 2021-01-13 22:00:59
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
On my second thought, maybe the reason for the exception is DNS caching. But it was not that. <br>
Reason for the exception : I used not allowed character in host name.
At that time, I should have known about host name convention better. you see, my home made host name is `api_call_server` now let's see what characters are allowed for naming host.

### The allowed Characters in Host Name convention 
1. a-z, A-Z  
2. 0-9 
3. - 
 These are all. No others. I'll keep in mind I cannot use under bar in Url. Only Hyphen would work. So I change host name from `api_call_server` to `api-call-server. After changing, I no longer saw 400 bad request.
Before finishing the post, I'd like to adjust convention for url too. 

### The allowed Characters in Url Name convention 
Always safe to use: `  A-Z a-z 0-9 - . _ ~ ( ) ' ! * : @ , ;` 
Not safe to use: (below image from [stackOverFlow](https://stackoverflow.com/questions/695438/what-are-the-safe-characters-for-making-urls))
![url convention](https://user-images.githubusercontent.com/35620531/104724934-bc2fbc80-5774-11eb-8e14-834e49730680.png)
In not safe, there are two concepts. Reserved and unsafe. 
1. Reserved: literally reserved for system. You can see those letters in Linux env a lot. Safety of Url is not static when url containing reserved character. I think I'd better not use them. 
2. Unsafe: just do not use them. If I want to use one of them, I have to percent encoding and it's on RFC. 

### PLUS: only use lower case in Url 
 Lowercase and Uppercase are both in the list, but we had better use Lowercase when it comes to making urls. Lowercase is more traditional way and considering UX, users don't have to press shift. 
And don't mix them too. (It called safe approach). With SEO(search engine optimize), google consider lowercase url and uppercase url are the same. <br>
For example, http://love.pizza.com/HOME.html and http://lova.pizza.com/home.html are the same. 
Data won't be able to have detail we wait for. Even though it's not critical, they recommend (1) stick to one version (2) use 301 redirect. 
I'm not so familiar with concept of SEO that I don't understand all of things. I'll leave the link and will read later again. [SEO and lower/upper matters](https://www.searchenginejournal.com/url-capitalization-seo/343369/#close)
