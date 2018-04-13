require 'vkontakte_api'
require 'yaml'
require 'pry'

PART_COUNT = 100
SLEEP_TIME = 2
PREFIX_STRING = "\t"

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

desc "get conversation_user_list"
task :get_conversation_user_list  => :make_vk_obj do
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

def get_prefix(level)
  PREFIX_STRING * level
end

def prefix_multiline(text, prefix)
  text.each_line.map {|line| prefix + line}.join
end

def get_photo_url(attachment)
  resolution_strings = attachment['photo'].keys.find_all {|str| str.include? 'photo_'}
  max_res = resolution_strings.map {|str| str.scan(/photo_([0-9]+)/).first.first.to_i }.max
  photo_url = attachment['photo']["photo_#{max_res}"]

  "#{photo_url}"
end

def get_wall_post(post, level)
  prefix = get_prefix(level)

  text = prefix_multiline(post['text'], get_prefix(level + 1))

  "#{prefix}Вложение (пост на стене или ответ на пост):\n#{text}"
end

def process_attachments(msg, level)
  prefix = get_prefix(level)

  return '' unless msg['attachments']

  result = msg.attachments.map do |attachment|
    case attachment['type']
    when  'photo'
      url = get_photo_url(attachment)

      "#{prefix}Вложение (фото): #{url}"
    when 'link'
      url = attachment['link']['url']
      title = attachment['link']['title']

      "#{prefix}Вложение (ссылка): #{title} (#{url})"
    when 'audio'
      artist = attachment['audio']['artist']
      title = attachment['audio']['title']

      "#{prefix}Вложение (аудио): #{artist} - #{title}"
    when 'video'
      title = attachment['video']['title']

      "#{prefix}Вложение (видео): #{title}"
    when 'wall'
      get_wall_post(attachment['wall'], level)
    when 'wall_reply'
      get_wall_post(attachment['wall_reply'], level)
    when 'doc'
      url = attachment['doc']['url'] 
      title = attachment['doc']['title']

      "#{prefix}Вложение (документ): #{title} (#{url})"
    else
      "#{prefix}Вложение (другое)."
    end
  end.join("\n")

  "#{result}\n"
end

def process_forwarded(msg, level)
  prefix = get_prefix(level)

  if msg['fwd_messages']
    forwarded_messages = msg['fwd_messages'].map { |msg| get_msg_txt(msg, level) }.join("\n")
    return "#{prefix}Forwarded messages:\n#{forwarded_messages}" 
  end

  return ''
end

def process_body(msg, prefix)
  if msg['body'].empty?
    body = "#{prefix}<empty message>\n"
  else
    body = "#{prefix_multiline(msg['body'], prefix)}\n"
  end
end

def get_header(msg, prefix)
  time = Time.at(msg['date'])
  sender = msg['from_id'] || msg['user_id']

  "#{prefix}[#{time} #{sender}]:\n"
end

def get_msg_txt(msg, level = 0)
  prefix = get_prefix(level)

  header = get_header(msg, prefix)
  body = process_body(msg, prefix)
  attachments = process_attachments(msg, level)
  forwarded = process_forwarded(msg, level + 1)

  header + body + attachments + forwarded
end

desc "message to text"
task :msg_to_txt => :make_vk_obj do
  target_id = ENV['target_id'].to_i
  messages_yaml = YAML::load(File.read("internal/messages_#{target_id}.yaml"))
  messages_txt = messages_yaml.reverse_each.map { |msg| get_msg_txt(msg) }.join("\n")

  File.write("output/messages_#{target_id}.txt", messages_txt)
end

desc "get conversations in yaml"
task :get_conversations_yaml  => :make_vk_obj do
  input = File.read('conversations_user_ids')
  user_ids = input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }

  user_ids.each do |target_id|
    ENV['target_id'] = target_id.to_s
    Rake::Task['get_messages'].reenable
    Rake::Task['get_messages'].invoke
  end
end

desc "get conversations in yaml"
task :get_conversations_yaml do
  input = File.read('conversations_user_ids')
  user_ids = input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }

  user_ids.each do |target_id|
    ENV['target_id'] = target_id.to_s
    Rake::Task['get_messages'].reenable
    Rake::Task['get_messages'].invoke
  end
end

desc "get conversations in txt"
task :get_conversations_txt do
  input = File.read('conversations_user_ids')
  user_ids = input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }

  user_ids.each do |target_id|
    ENV['target_id'] = target_id.to_s
    Rake::Task['msg_to_txt'].reenable
    Rake::Task['msg_to_txt'].invoke
  end
end

desc "clean output"
task :clean_output  => :make_vk_obj do
  targets = Dir.glob("output/*")
  FileUtils.rm(targets)
end