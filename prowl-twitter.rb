# With many thanks to John Mettraux for the original script as seen at
# http://jmettraux.wordpress.com/2008/11/04/ruby-twitter-growl/

require 'rubygems'  
require 'rufus/verbs' # gem rufus-verbs  
require 'rufus/lru' # gem rufus-lru  
require 'json' # gem json or json_pure  
require 'prowl'

puts 'wonder twit powers... activate!'

USER = 'user' #twitter user  
PASS = 'password' #twitter pass
APIKEY = 'prowl api key here' #prowl api key
  
raise 'USER, PASS, and/or APIKEY not set' if (not USER) or (not PASS)  

SEEN = LruHash.new(100) # max hash size  
  
def fetch_tweets  
  
  # by default, get replies, NOT the whole timeline
  # you could also duplicate this block to get direct messages,
  # but I get them in email so no big deal
  res = Rufus::Verbs.get(  
    "http://twitter.com"+  
    "/statuses/replies.json",  
    :hba => [ USER, PASS ])  
  
  raise "#{res.code} != 200" if res.code.to_i != 200  
  
  o = JSON.parse(res.body)  
  
  o.each do |message|  
  
    id = message['id']  
    next if SEEN[id]  
    
    user = message['user']
  
    Prowl.add(APIKEY, { :application => "Twitter",
                        :event => "Reply",
                        :description => user['name'] + ': ' + message['text']})
    
    SEEN[id] = true  
  end
  puts 'checked for messages at ' + Time.new.to_s  
end  
  
loop do  
  
  begin  
    fetch_tweets  
  rescue Exception => e  
    p e  
  end  
  
  sleep 180 # seconds  
end  
