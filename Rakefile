require 'vkontakte_api'
require 'yaml'
require 'pry' # FIXME: нужно для отладки, потом выбросить нафиг на мороз

config = YAML::load(File.read("config.yaml"))

task :get_auth_url do
  url = VkontakteApi.authorization_url(type: :client, client_id: config['client_id'], scope: [:friends, :photos, :audio, :video, :pages, :status, :notes, :messages, :wall])
  puts url
end

task :get_token do
  token = ENV['vk_response_url'].scan(/access_token=([^&]+)/).first.first
  File.write('internal/token', token)
end

task :clear_token do
  File.rm('internal/token')
end

task :playground do
  token = File.read('internal/token')
  vk = VkontakteApi::Client.new(token)
  binding.pry
end

task :get_conversations do
  token = File.read('internal/token')
  vk = VkontakteApi::Client.new(token)
  
  dialog_hash = vk.messages.getDialogs(v: 5.73, preview_length: 1) # FIXME: пока что скачивает не всё
  dialog_count = dialog_hash[:count]
  puts "Conversations: #{dialog_count}"

  user_ids = dialog_hash[:items].map do |dialog|
    dialog[:message][:user_id]
  end

  users = vk.users.get(user_ids: user_ids, v: 5.74) # вопрос в том. какое максимальное число ID ей можно передать

  users_str = users.map do |user|
    "#{user[:id]} \# #{user[:first_name]} #{user[:last_name]}"
  end.join("\n")

  puts users_str

  out = File.open('conversation_ids','w') do |f|
    f.puts users_str
  end
end

task :parse_conversations do
  input = File.read('conversation_ids')

  ids = input.split(/\n/).map do |elt|
    elt.scan(/([0-9]+) .*/).first.first.to_i
  end

  puts ids.inspect
end