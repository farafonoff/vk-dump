require 'vkontakte_api'
require 'yaml'
require 'pry'
require 'rake/clean'

require './lib/configuration.rb'
require './lib/common.rb'
require './lib/messages.rb'
require './lib/attachments.rb'
require './lib/posts.rb'
require './lib/avatars.rb'

desc "Remove only output files."
task :clobber_nodep do
  Rake::Cleaner.cleanup_files(CLOBBER)
end

task :make_vk_obj do
  token = File.read('internal/token')
  @vk = VkontakteApi::Client.new(token)
end

desc "playground"
task :playground => :make_vk_obj do
  binding.pry
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
    FileUtils::rm 'internal/token', :force => true
  end
end

namespace 'msg' do
  desc "get conversation list"
  task :get_conversation_list, :output_filename do |f, args|
    input_filename = 'internal/conversations.yaml'

    Rake::Task[input_filename].invoke  
    conversations = YAML::load(File.read(input_filename))
    conversations_txt = get_conversation_list_txt(conversations)

    if args[:output_filename]
      File.open(args[:output_filename], 'w') { |f| f.puts(conversations_txt) }
    else
      puts conversations_txt
    end
  end

  desc "get conversations in md"
  task :get_conversations_in_md, :name do |f, args|
    abort 'Specify filename!' unless args[:name]

    input = File.read(args[:name])  
    user_ids = get_conversation_user_ids(input)
    
    puts "User IDs: #{user_ids.join(', ')}"

    user_ids.each do |target_id|
      puts "processing: #{target_id}"
      Rake::Task["output/msg#{target_id}.md"].invoke
    end
  end

  rule /^internal\/conversations\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    conversations = get_conversation_list
    File.write(f.name, YAML::dump(conversations))
  end

  rule /^internal\/msg([0-9]+)\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_from_filename(f.name)
    messages = get_messages(target_id).to_yaml
    File.write(f.name, messages)
  end

  rule /^output\/msg([0-9]+)\.md$/ => [ 
    proc {|name| "internal/msg#{get_id_from_filename(name)}.yaml" }
  ] do |f|
    target_id = get_id_from_filename(f.name)
    
    input_name = "internal/msg#{target_id}.yaml"
    messages_yaml = YAML::load(File.read(input_name))
    messages_md = msg_yaml_to_md(messages_yaml)

    File.write(f.name, messages_md)
  end
end

namespace 'post' do
  desc "get wall"
  task :get_wall => 'output/wall.md'

  rule /^internal\/wall\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    wall_yaml = get_wall.to_yaml
    File.write('internal/wall.yaml', wall_yaml)
  end

  rule /^output\/wall\.md$/ => 'internal/wall.yaml' do |f|
    Rake::Task[:make_vk_obj].invoke

    input = YAML.load(File.read('internal/wall.yaml'))
    posts = input[:posts]
    profiles = input[:profiles]

    posts_md = posts.map { |post| get_post_md(post, profiles) }.join("\n")
    File.write('output/wall.md', posts_md)
  end
end

namespace 'avatars' do
  desc "get avatars"
  task :get => 'output/avatars.md'

  rule /^internal\/avatars\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    avatars_yaml = get_avatars.to_yaml
    File.write('internal/avatars.yaml', avatars_yaml)
  end

  rule /^output\/avatars\.md$/ => 'internal/avatars.yaml' do |f|
    Rake::Task[:make_vk_obj].invoke

    input = YAML.load(File.read('internal/avatars.yaml'))
    photos_mds = input.map { |avatar| get_avatar_md(avatar) }
    photos_md = photos_mds.join("\n")
    
    File.write(f.name, photos_md)
  end
end