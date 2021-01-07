---
layout: post 
title: "[Linux] Writing shell script"
date: 2021-01-05 20:39:40
author: Jamie Lee
categories: Backend
tags:	linux
cover:  "/assets/img/ubuntu.png"
pagination: 
  enabled: true
---

Today, I handed over a project to a teammate I took over from a colleague who was about to quit the job. The one thing I was concerning is the fact that the team mate 
will take over whole part of the project. It means she is going to do deploy as well and she is quite new with Linux.  I didn't think it is a good idea to let her know all the command using for deplyoment.
So I decided to making shell script containing the command! (I've wanted to learn about shell script too)

The most important beginning of shell script!

```git
#!/bin/bash
```
As far as I remember, all the shell script is working with 'bash' file in bin directory. To execute shell script, do not forget to wirte #!/bin/bash line. 

```git

touch test_bash.sh 
~ editing bash file ~

chmod +x test_bash.sh
```

Give the bash file you were writing execution roll. Bash file is for execution after all. This is almost everything I know about shell script. Now let's take a look at the bash file I wrote today. 

```git
#!/bin/bash 

# add some comment to let people know what this bash file for. 

pw="password_I_used_in_server"

echo ${pw} | sudo -kS systemctl reload shiny-server 
sleep .5

echo ${pw} | sudo -kS systemctl status shiny-server | cat 
echo "Successfully updated aiv"
```
## point
1. I wanted to make bash file which passes writing password in the middle of execution. So I just give password as param. I know It's quite bad for security. I must think other way next time.
2. sudo -kS option <br>
'S' is for getting password from 'echo' command. It means it will catch anything from stdin. 'k' is for reset timestamp. When the timestamp remains in sudo command, it might cause some error.
3. sleep .5 (5 is 5 seconds, .5 is 5 millie seconds). <br>
I just want to put some delay from reloading. 
4. systemctl status shiny-server | cat <br>
I want to show the status of service at the last part of execution for making sure it's working. But as you know, after reading status, I have to do the typing to quit. So I just make the status printed. It doesn't need quiting. 

<hr> 

To be honest, I already use bash command to deploy jar file and manage log file. Thoese are what I'm using now. (need to improve and do more customize later.)

```git
    #!/bin/bash
   
    DATE=`date +'%Y%m%d'`
    echo $DATE
   
    ETC_JAVA_OPTS=-XX:+UseStringDeduplication
   
    nohup java -Xms128m -Xmx128m -XX:NewRatio=1 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps     -XX:+PrintGCDateStamps -Xloggc:./gc.log -Dspring.profiles.active=prod $* -jar file_name.jar >> ./server.log &
    tail -F server.log
```

This one is for deployment of Spring project. There are several java running option(will study later). It should be running in background. Unless, it will get stopped when I close a terminal which is running jar.  
So I had better use nohup command. 
The file is not just about running jar file. It makes log file keep going. '>>' command means stdout will be remained in a file located right behind the command. Tail is just to make sure the jar file is successfully built. 


```git
  #!/bin/bash
 
  DATE=`date +'%Y%m%d'`
  DATE2=`date +'%Y%m'`
 
  LOG_FILENAME=backup_server$DATE.log
  LOG_DIRNAME="backup_server${DATE2}_log"
 
 
  if [ -e $LOG_FILENAME ]
  then
      echo "$LOG_FILENAME exist"
  else
      echo "cp server.log $LOG_FILENAME"
      cp server.log $LOG_FILENAME
      cp -f /dev/null server.log
 
      echo "now tail.."
  fi
 
  # moving log to dir file script
  if [ -e $LOG_DIRNAME ]
  then
   :
  else
   mkdir $LOG_DIRNAME
 
  fi
 
  mv $LOG_FILENAME $LOG_DIRNAME
 
  tail -F server.log
```
This one is for managing log file. These two main process are like that. (1) make current log file to backup file and make new log file to be used soon, (2) move freshly made backup log file to 
proper log file directory. (Mostly manage by year and month. YYYYMD)

## /dev/null 
What is /dev/null in the bash command? It's like official empty file of Linux. /dev/null file is always empty. It has to be. 
In the bash, I didn't delete server.log file, because I'll keep using it after moving all contents in file to backup file. In this purpose, /dev/null is best choice.
Think like this. 

1. /dev/null is always empty 
2. Copy content in /dev/null to server.log
3. It means content(which is empty) is copied to server.log. Basically, server.log file should be empty too. 
4. You can also use 'cat /dev/null > server.log'
5. cat will print /dev/null content(which is empty) and '>' will pass the content to specific file(server.log).

Using this command makes so easy to remove data and make file size to zero. I have a feeling it will be super usful managing linux server memory!

 
