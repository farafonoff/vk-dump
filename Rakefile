require 'vkontakte_api'
require 'yaml'
require 'pry'
require 'rake/clean'

Hashie.logger = Logger.new(nil)
@config = YAML::load(File.read("config.yaml"))

require './methods.rb'

API_VERSION = 5.74

VkontakteApi.configure { |config| config.api_version = API_VERSION.to_s }

SOURCE_FILES = Rake::FileList.new("internal/*yaml")
OUTPUT_FILES = Rake::FileList.new("output/*txt")

CLEAN.include(SOURCE_FILES)
CLOBBER.include(OUTPUT_FILES)

desc "Remove only output files."
task :clobber_nodep do
  Rake::Cleaner.cleanup_files(CLOBBER)
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

task :make_vk_obj do
  token = File.read('internal/token')
  @vk = VkontakteApi::Client.new(token)
end

desc "playground"
task :playground => :make_vk_obj do
  binding.pry
end

namespace 'single' do
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

  rule /^internal\/wall\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    posts_count = @vk.wall.get(count: 1, v: API_VERSION)['count']
    pages_count = (posts_count / @config['part_count'].to_f).ceil

    posts = []
    (0...pages_count).each do |i|
      current_posts = @vk.wall.get(count: @config['part_count'], offset: @config['part_count'] * i, v: API_VERSION)['items']
      posts.push *current_posts

      sleep @config['sleep_time']
    end

    File.write('internal/wall.yaml', YAML.dump(posts))
  end

  rule /^output\/wall\.txt$/ => 'internal/wall.yaml' do |f|
    posts_raw = YAML.load(File.read('internal/wall.yaml'))

    posts = posts_raw.map { |post_raw| make_post(post_raw) }.join("\n\n")
    File.write('output/wall.txt', posts)
  end

  rule /^output\/wall_playground\.txt$/ => 'internal/wall.yaml' do |f|
    posts_raw = YAML.load(File.read('internal/wall.yaml')).find_all {|post| post.attachments}

    posts = posts_raw.map { |post_raw| get_wall_post(post_raw, 0) }.join("\n\n")
    File.write('output/wall_playground.txt', posts)
  end
end

namespace 'multiple' do
  desc "get conversation list"
  task :get_conversation_list, :name  do |f, args|
    Rake::Task[:make_vk_obj].invoke  

    output = get_conversation_list.join("\n")
        
    if args[:name]
      File.open(args[:name], 'w') { |f| f.puts(output) }
    else
      puts output
    end
  end

  # desc "multiple targets: get conversations in yaml"
  # task :get_conversations_yaml do
  #   input = File.read('conversations_user_ids')
  #   user_ids = get_user_ids(input)
  #
  #   user_ids.each do |target_id|
  #     ENV['target_id'] = target_id.to_s
  #     Rake::Task['get_messages_yaml'].reenable
  #     Rake::Task['get_messages_yaml'].invoke
  #   end
  # end
end