require 'rubygems'
require 'bundler'
require 'json'

# pass media file to weibo, without saving it locally.
require 'open-uri'
# unshorten t.co etc. (these urls is forbidden for weibo)
require 'unshorten'

Bundler.require

require 'twitter/json_stream'
require './secret' if File.exist?("./secret.rb")

TWITTER_CONSUMER_KEY       ||= ENV['TWITTER_CONSUMER_KEY']
TWITTER_CONSUMER_SECRET    ||= ENV['TWITTER_CONSUMER_SECRET']
TWITTER_OAUTH_TOKEN        ||= ENV['TWITTER_OAUTH_TOKEN']
TWITTER_OAUTH_TOKEN_SECRET ||= ENV['TWITTER_OAUTH_TOKEN_SECRET']
FOLLOWS                    ||= ENV['FOLLOWS']

WEIBO_APP_KEY              ||= ENV['WEIBO_APP_KEY']
WEIBO_APP_SECRET           ||= ENV['WEIBO_APP_SECRET']
WEIBO_ACCESS_TOKEN         ||= ENV['WEIBO_ACCESS_TOKEN']

def unshortten(url)
  Unshorten[url]
end

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    # user stream
    # this will make a twitter client.
    #:host => "userstream.twitter.com",
    #:path => "/1.1/user.json",

    # read only my tweets
    :path    => "/1.1/statuses/filter.json?follow=#{FOLLOWS}",

    :oauth => {
      :consumer_key    => TWITTER_CONSUMER_KEY,
      :consumer_secret => TWITTER_CONSUMER_SECRET,
      :access_key      => TWITTER_OAUTH_TOKEN,
      :access_secret   => TWITTER_OAUTH_TOKEN_SECRET
    },
    :ssl => true
  )

  stream.each_item do |item|
    $stdout.print "item: #{item}\n"

    tw_json = JSON.parse(item)

    # delete
    # item: {"delete":{"status":{"id":yyy,"user_id":xxx,"id_str":"yyy","user_id_str":"xxx"}}}
    unless tw_json['delete'].nil?
      $stdout.print "DELETE: #{item}\n"
      $stdout.flush
      next
    end
    text = tw_json['text']
    $stdout.print "text: #{text}\n"
    # replace t.co url with original url, because sina band
    text = text.gsub(/http\:\/\/t\.co\/[a-z0-9A-Z]+/){|u| unshortten u }
    text = text.gsub(/https\:\/\/t\.co\/[a-z0-9A-Z]+/){|u| unshortten u }

    # @user_name to user_name﹫twitter.
    # pay attention on the difference between '@' and '﹫'
    text = text.gsub(/\B@([A-Za-z0-9_]{1,15})/,'\1﹫twitter')
    # rehash #\w -> #\w#
    # TODO: can match english words only.
    text = text.gsub(/\B#([\u2E80-\u9FFFA-Za-z0-9_]{1,15})/,'#\1#')

    $stdout.print "after parse text: #{text}\n"
    $stdout.flush

    # http://pbs.twimg.com/media/xxx.png
    post_media_url = tw_json['entities']['media'].first['media_url'] rescue nil

    WeiboOAuth2::Config.api_key = WEIBO_APP_KEY
    WeiboOAuth2::Config.api_secret = WEIBO_APP_SECRET
    weibo = WeiboOAuth2::Client.new
    weibo.get_token_from_hash({:access_token => WEIBO_ACCESS_TOKEN, :expires_at => 86400 })
    begin
        if post_media_url.nil?
          weibo.statuses.update(text)
        elsif post_media_url.end_with?('png') or post_media_url.end_with?('jpg') or post_media_url.end_with?('jpeg')
          $stdout.print "media_url: #{post_media_url}\n"
          weibo.statuses.upload(text, open(post_media_url), {})
        end
        $stdout.print "post weibo OK!\n"

    rescue Exception => e
        $stdout.print "post weibo status error: #{e}\n"
    end
    $stdout.flush


  end

  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end

  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end
  
  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end
}