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

namespace 'auth' do
  desc "get auth url"
  task :get_url => :rm_token do
    scope_definition = [:friends, :photos, :audio, :video, :pages, :status, :notes, :messages, :wall]
    url = VkontakteApi.authorization_url(type: :client, client_id: @config['client_id'], scope: scope_definition)
    puts url
  end

  desc "get token"
  task :get_token, [:url] do |t, args|
    url = args[:url]
    token = get_token(url)
    File.write('internal/token', token)
  end

  desc "remove token"
  task :rm_token do
    FileUtils::rm('internal/token')
  end
end

task :make_vk_obj do
  token = File.read('internal/token')
  @vk = VkontakteApi::Client.new(token)
end

desc "playground"
task :playground => :make_vk_obj do
  binding.pry
end

file 'conversation_list' do |f|
  Rake::Task[:make_vk_obj].invoke  

  conversations = get_conversation_list
  File.write(f.name, conversations.join("\n"))
end

rule /^internal\/messages([0-9]+)\.yaml$/ do |f|
  Rake::Task[:make_vk_obj].invoke

  target_id = get_index(f.name)
  messages = get_messages(target_id).to_yaml
  File.write(f.name, messages)
end

rule /^output\/messages([0-9]+)\.txt$/ => [ 
  proc {|name| "internal/messages#{get_index(name)}.yaml" }
] do |f|
  target_id = get_index(f.name)
  
  input_name = "internal/messages#{target_id}.yaml"
  messages_yaml = YAML::load(File.read(input_name))
  
  messages_txt = msg_yaml_to_txt(messages_yaml)
  File.write(f.name, messages_txt)
end

# desc "multiple targets: get conversations in yaml"
# task :get_conversations_yaml do
#   input = File.read('conversations_user_ids')
#   user_ids = get_user_ids(input)

#   user_ids.each do |target_id|
#     ENV['target_id'] = target_id.to_s
#     Rake::Task['get_messages_yaml'].reenable
#     Rake::Task['get_messages_yaml'].invoke
#   end
# end

# desc "multiple targets: get conversations in txt"
# task :get_conversations_txt do
#   input = File.read('conversations_user_ids')
#   user_ids = get_user_ids(input)

#   user_ids.each do |target_id|
#     ENV['target_id'] = target_id.to_s
#     Rake::Task['get_messages_txt'].reenable
#     Rake::Task['get_messages_txt'].invoke
#   end
# end

# clean-up

# desc "clean up: clear output"
# task :clear_output do
#   targets = Dir.glob("output/*")
#   FileUtils.rm(targets)
# end

# desc "clean up: clear internal"
# task :clear_internal do
#   targets = Dir.glob("internal/*yaml")
#   FileUtils.rm(targets)
# end

# desc "clean up: clear token"
# task :clear_token do
#
# end
