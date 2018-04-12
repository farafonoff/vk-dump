require 'vkontakte_api'
require 'yaml'
require 'pry'

PART_COUNT = 100
SLEEP_TIME = 2
VK_API_VERSION = 5.74

config = YAML::load(File.read("config.yaml"))

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
  dialog_count = @vk.messages.getDialogs(v: VK_API_VERSION, count: 0)['count']
  dialog_parts = (dialog_count.to_f / PART_COUNT).ceil

  File.open('conversations_user_ids','w') do |output|
    dialog_parts.times do |i|
      get_dialogs_params = { v: VK_API_VERSION, preview_length: 1, count: PART_COUNT, offset: i * PART_COUNT }
      current_ids_part = @vk.messages.getDialogs(get_dialogs_params)['items'].map {|elt| elt['message']['user_id'] }
      users_part = @vk.users.get(user_ids: current_ids_part, v: VK_API_VERSION)
  
      users_part.each { |user| output.puts "#{user[:id]} \# #{user[:first_name]} #{user[:last_name]}" }

      sleep SLEEP_TIME
    end
  end
end

desc "parse conversations"
task :parse_conversations  => :make_vk_obj do
  input = File.read('conversations_user_ids')
  user_ids = input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }

  File.open('conversation_counts','w') do |output|
    user_ids.each do |user_id|
      messages_count = @vk.messages.getHistory(user_id: user_id, count: 0, v: VK_API_VERSION)['count']
  
      output.puts "#{user_id}: #{messages_count}"
      
      sleep SLEEP_TIME
    end
  end
end