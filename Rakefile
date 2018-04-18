require 'vkontakte_api'
require 'yaml'
require 'pry'

@config = YAML::load(File.read("config.yaml"))

require './methods.rb'

VkontakteApi.configure do |config|
  config.api_version = '5.74'
  
  config.log_requests  = false
  config.log_responses = false
end

# auth

desc "auth: get auth url"
task :get_auth_url do
  scope_definition = [:friends, :photos, :audio, :video, :pages, :status, :notes, :messages, :wall]
  url = VkontakteApi.authorization_url(type: :client, client_id: @config['client_id'], scope: scope_definition)
  puts url
end

desc "auth: get token"
task :get_token do
  url = ENV['vk_response_url']
  token = get_token(url)
  File.write('internal/token', token)
end

task :make_vk_obj do
  token = File.read('internal/token')
  @vk = VkontakteApi::Client.new(token)
end

# messages: single message

desc "single target: get messages in yaml"
task :get_messages_yaml => :make_vk_obj do
  target_id = ENV['target_id'].to_i
  messages = get_messages(target_id).to_yaml
  
  output_name = "internal/messages_#{target_id}.yaml"
  File.write(output_name, messages)
end

desc "single target: get messages in text"
task :get_messages_txt do
  target_id = ENV['target_id'].to_i
  
  input_name = "internal/messages_#{target_id}.yaml"
  messages_yaml = YAML::load(File.read(input_name))
  
  messages_txt = msg_yaml_to_txt(messages_yaml)
  output_name = "output/messages_#{target_id}.txt"
  File.write(output_name, messages_txt)
end

# messages: multiple messages

desc "multiple targets: get conversation list"
task :get_conversation_list  => :make_vk_obj do
  conversations = get_conversation_list
  output_name = 'conversations_user_ids'
  File.write(output_name, conversations.join("\n"))
end

desc "multiple targets: get conversations in yaml"
task :get_conversations_yaml do
  input = File.read('conversations_user_ids')
  user_ids = get_user_ids(input)

  user_ids.each do |target_id|
    ENV['target_id'] = target_id.to_s
    Rake::Task['get_messages_yaml'].reenable
    Rake::Task['get_messages_yaml'].invoke
  end
end

desc "multiple targets: get conversations in txt"
task :get_conversations_txt do
  input = File.read('conversations_user_ids')
  user_ids = get_user_ids(input)

  user_ids.each do |target_id|
    ENV['target_id'] = target_id.to_s
    Rake::Task['get_messages_txt'].reenable
    Rake::Task['get_messages_txt'].invoke
  end
end

# clean-up

desc "clean up: clear output"
task :clear_output do
  targets = Dir.glob("output/*")
  FileUtils.rm(targets)
end

desc "clean up: clear internal"
task :clear_internal do
  targets = Dir.glob("internal/*yaml")
  FileUtils.rm(targets)
end

desc "clean up: clear token"
task :clear_token do
  File.rm('internal/token')
end

# playground

desc "playground"
task :playground => :make_vk_obj do
  binding.pry
end