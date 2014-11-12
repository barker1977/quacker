#
# Name       : Agent Activity
# Date       : 2014-11-11
# Author     : Matt Barker
# Description: Calls the ZD voice API and sends the agent activity
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
zd_endpoint = 'https://' + zd_subdomain + '.zendesk.com/api/v2/channels/voice/stats/historical_queue_activity.json?include=recent_agents_activity'
puts 'Endpoint:' + zd_endpoint

response = RestClient::Request.new({:method => :get,
                                    :user => zd_user, 
                                    :password => zd_token, 
                                    :url => zd_endpoint}).execute

# parse ie
result = JSON.parse response.body
puts result

# create the hash/json object for ducksboard
boards = []
board = {"board"=>boards}
payload = {"value"=>board}

#process each of the agents in the result set
result["historical_queue_activity"]["agents_activity"].each { |agent|
  unless agent["status_code"] == "not_available" then
    agent_details = {"name"=>agent["name"], "values" => [agent["calls_accepted"].to_s, agent["status"]]}
  end
  boards.push(agent_details) }
  
puts payload.to_json

# send the payload to Ducksboard
response = RestClient::Request.new({
             :method => :put,
             :user => db_token, 
             :url => 'https://push.ducksboard.com/v/' + db_widget_id,
             :headers => {
               :content_type => :json},
             :payload => payload.to_json}).execute

puts 'Ducksboard response: ' + response.code.to_s
