twitter2weibo
=============

monitor Twitter using Twitter Streaming API and repost to sina weibo 

Deploy to heroku
====

step 1. clone this repo:

git clone https://github.com/liubin0329/twitter2weibo.git


step 2. create a heroku app, t2w for example.

add heroku repo to remote(git@heroku.com:t2w.git)

$ heroku git:remote -a twitter2weibo

$ git remote -v

heroku  git@heroku.com:t2w.git (fetch)
heroku  git@heroku.com:t2w.git (push)
origin  https://github.com/liubin0329/twitter2weibo.git (fetch)
origin  https://github.com/liubin0329/twitter2weibo.git (push)

step 3. push to herko

$ git push heroku master

step 4. stop web process if started

stop web process before start twitter2weibo process

$ heroku scale web=0

or you will be charged by $34/month.

step5. start twitter2weibo

$ heroku scale twitter2weibo=1

and to ensure the log, use

$ heroku logs --tail

Feedbacks
====

mailto: liubin0329@gmail.com

Special thanks
====
this blog:
http://morizyun.github.io/blog/ruby-twitter-stream-api-heroku/

and this repo:
https://github.com/morizyun/tweetscan
