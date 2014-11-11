#
# Name       : Voice Current Queue
# Date       : 2014-11-11
# Author     : Matt Barker
# Description: Calls the ZD voice API and sends the voice queue
#              status to Ducksboard
# Gems       : rest-client
# Parameters : -ZD subdomain
#              - ZD username
#              -ZD password/token
#              -Ducksboard widget id
#              -Ducksboard token
#
require 'rest_client'
require 'json'

if ARGV.count != 5 then
  puts "Usage: ruby currentQueue.rb [zd_user] [zd_password] [db_widget_id] [db_token]"
  exit 1 
end

zd_subdomain = ARGV[0]
zd_user = ARGV[1]
zd_token = ARGV[2]
db_widget_id = ARGV[3]
db_token = ARGV[4]

# Get the data from Zendesk
zd_endpoint = 'https://' + zd_subdomain + '.zendesk.com/api/v2/channels/voice/stats/current_queue_activity.json'
puts 'Endpoint:' + zd_endpoint

response = RestClient::Request.new({:method => :get,
                                    :user => zd_user, 
                                    :password => zd_token, 
                                    :url => zd_endpoint}).execute

# parse ie
result = JSON.parse response.body
puts result

current_queue = result["current_queue_activity"]["calls_waiting"].to_s
timestamp = Time.now.to_i.to_s
payload = '{ "timestamp": ' + timestamp+ ', "value": ' + current_queue+ '}'

# send the payload to Ducksboard
response = RestClient::Request.new({
             :method => :put,
             :user => db_token, 
             :url => 'https://push.ducksboard.com/v/' + db_widget_id,
             :headers => {
               :content_type => :json},
             :payload => payload}).execute

puts 'Ducksboard response: ' + response.code.to_s
