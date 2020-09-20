---
layout: post 
title: "[Git]Making forked repo to standalone repo"
date: 2020-09-17
excerpt: "make forked repo to my own feat.planting grass"
tags: [index, absinthe4902]
feature: https://www.google.com/url?sa=i&url=https%3A%2F%2Fcommons.wikimedia.org%2Fwiki%2FFile%3AGit-logo.svg&psig=AOvVaw3byQEWfvG09a9l9D0tXjao&ust=1600521072443000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCLD1geHj8usCFQAAAAAdAAAAABAD
comments: false
---

It's been a graceful four days since starting one day one commit project. But something weird happen with yesterday commit data. I certainly updated a repo for [github.io](http://github.io). I could see the record of it in the repo. However the commit wasn't recored in the contributon table in overview page. This contributon table is everything about one day one commit, so I have to dig in to see what's going wrong. 

> Why are my contributions not showing up on my profile?

[github support](https://docs.github.com/en/github/setting-up-and-managing-your-github-profile/why-are-my-contributions-not-showing-up-on-my-profile)

It doesn't matter how to make contribution for active repository. Forking, coding, adding, commiting and pulling with request... The master owner will check on that later. Or you can write issue or asking the owner join you as a collaborator. But these are for actual solution of team repo. (or open source) I'm in different situation. I just copied this beautiful theme repo to use as my [github.io](http://github.io) template. I'm not going to make real contribution for the repo. It's read-only archieved.

# Make your forked repo to standalone repo

AKA make the forked repo to your own repository. This is the easiest way to fix contribution not showing problem. Thiking this as sawp operation between repos! 

- clone the repo you want to use as [github.io](http://github.io) theme. (**Do not fork**)
git clone git@github.com:USERNAME/REPO.git
- Delete the repo in Remote Github (if you have one)
- Create new repo in Github
- change remote url in your local repo (you can skip this if the url already indicate your own [github.io](http://github.io) repo) 
how to check: git remote -v
how to change: git remote set-url origin git@github.com:USERNAME/NEW_REPO.git
- git push
- 😆 now you have standalone repo! easy peasy

My problem was forking the repo at the very first time. Keep in mind cloning [github.io](http://github.io) repo to use! And normal parpose of repo is okay to fork for sure. 

# Reference

[GitHub: make fork an “own project”](https://stackoverflow.com/questions/18390249/github-make-fork-an-own-project)
