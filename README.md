twitter2weibo
=============

monitor (one's or ones's ) Twitter using Twitter Streaming API and repost to sina weibo. 

Run locally
====

if your want to run it locally, you can simply run :
```
$ foreman start
```

Deploy to heroku
====

step 1. clone this repo:
==
```
$ git clone https://github.com/liubin0329/twitter2weibo.git
```
step 2. create a heroku app, t2w for example.
==
add heroku repo to remote(git@heroku.com:t2w.git)

```
$ cd twitter2weibo
$ heroku git:remote -a twitter2weibo  
$ git remote -v
heroku  git@heroku.com:t2w.git (fetch)
heroku  git@heroku.com:t2w.git (push)
origin  https://github.com/liubin0329/twitter2weibo.git (fetch)
origin  https://github.com/liubin0329/twitter2weibo.git (push)
```

step 3. push to herko
==
```
$ git push heroku master
```
step 4. stop web process if started
==
stop web process before start twitter2weibo process  
(by default heroku will start a **web** process in your first deploy)
```
$ heroku scale web=0
```
**or you will be charged by $34.5/month.**

step5. start twitter2weibo
==

first, setup ENV
```
heroku config:set WEIBO_APP_KEY=''
heroku config:set WEIBO_APP_SECRET=''
heroku config:set WEIBO_ACCESS_TOKEN=''

heroku config:set TWITTER_CONSUMER_KEY=''
heroku config:set TWITTER_CONSUMER_SECRET=''
heroku config:set TWITTER_OAUTH_TOKEN=''
heroku config:set TWITTER_OAUTH_TOKEN_SECRET=''
heroku config:set FOLLOWS=''
```
**attention:**  
1. FOLLOWS can only use numbers.
2. no space chars around "=" in the 'key=value' content.

then start twitter2weibo process(dyno)
```
$ heroku scale twitter2weibo=1
```
and to ensure the log, use
```
$ heroku logs --tail
```
if normally started, you will see the log like below:

>2014-01-24T03:21:40.806464+00:00 heroku[twitter2weibo.1]: Starting process with command `bundle exec ruby twitter2weibo.rb`  
2014-01-24T03:21:41.421273+00:00 heroku[twitter2weibo.1]: State changed from starting to up

Feedbacks
====

mailto: liubin0329@gmail.com

Special thanks
====
this blog:
http://morizyun.github.io/blog/ruby-twitter-stream-api-heroku/

and this repo:
https://github.com/morizyun/tweetscan
