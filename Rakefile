require 'vkontakte_api'
require 'yaml'
require 'pry'

PART_COUNT = 100
SLEEP_TIME = 2

config = YAML::load(File.read("config.yaml"))

VkontakteApi.configure do |config|
  config.api_version = '5.74'
  
  config.log_requests  = false
  config.log_responses = false
end

desc "get auth url"
task :get_auth_url do
  scope_definition = [:friends, :photos, :audio, :video, :pages, :status, :notes, :messages, :wall]
  url = VkontakteApi.authorization_url(type: :client, client_id: config['client_id'], scope: scope_definition)
  puts url
end

desc "get token"
task :get_token do
  token = ENV['vk_response_url'].scan(/access_token=([^&]+)/).first.first
  File.write('internal/token', token)
end

desc "clear token"
task :clear_token do
  File.rm('internal/token')
end

task :make_vk_obj do
  token = File.read('internal/token')
  @vk = VkontakteApi::Client.new(token)
end

desc "playground"
task :playground => :make_vk_obj do
  binding.pry
end

desc "get conversations"
task :get_conversations  => :make_vk_obj do
  dialog_count = @vk.messages.getDialogs(count: 0)['count']
  dialog_parts = (dialog_count.to_f / PART_COUNT).ceil

  File.open('conversations_user_ids','w') do |output|
    dialog_parts.times do |i|
      get_dialogs_params = { preview_length: 1, count: PART_COUNT, offset: i * PART_COUNT }
      current_ids_part = @vk.messages.getDialogs(get_dialogs_params)['items'].map {|elt| elt['message']['user_id'] }
      users_part = @vk.users.get(user_ids: current_ids_part)
  
      users_part.each { |user| output.puts "#{user[:id]} \# #{user[:first_name]} #{user[:last_name]}" }

      sleep SLEEP_TIME
    end
  end
end

desc "get messages"
task :get_messages => :make_vk_obj do
  target_id = ENV['target_id'].to_i

  messages_count = @vk.messages.getHistory(user_id: target_id, count: 0)['count']
  messages_parts = (messages_count.to_f / PART_COUNT).ceil
  
  messages = (0...messages_parts).reduce([]) do |result,i|
    messages_part = @vk.messages.getHistory(user_id: target_id, count: PART_COUNT, offset: i * PART_COUNT)['items']
    sleep SLEEP_TIME
    result += messages_part
  end

  File.open("internal/messages_#{target_id}.yaml","w") do |f|
    f.write(messages.to_yaml)
  end
end

desc "message to text"
task :msg_to_txt => :make_vk_obj do
  target_id = ENV['target_id'].to_i
  messages_yaml = YAML::load(File.read("internal/messages_#{target_id}.yaml"))

  messages_txt = messages_yaml.reverse_each.map do |msg|
    time = Time.at(msg['date']) #.strftime(TIME_FORMAT)
    sender = msg['from_id']
    
    header = "[#{time} #{sender}]:\n"

    if msg['body'].empty?
      body = "<empty message>\n"
    else
      body = "#{msg['body']}\n"
    end
    
    footer = ''
    footer += "Has attachments\n" if msg['attachments']
    footer += "Has forwarded messages\n" if msg['fwd_messages']

    header + body + footer
  end.join("\n")

  File.write("output/messages_#{target_id}.txt", messages_txt)
end

# desc "parse conversations"
# task :parse_conversations  => :make_vk_obj do
#   input = File.read('conversations_user_ids')
#   user_ids = input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }

#   File.open('conversation_counts','w') do |output|
#     user_ids.each do |user_id|
#       messages_count = @vk.messages.getHistory(user_id: user_id, count: 0)['count']
  
#       output.puts "#{user_id}: #{messages_count}"
      
#       sleep SLEEP_TIME
#     end
#   end
# end