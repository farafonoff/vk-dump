require 'vkontakte_api'
require 'yaml'
require 'pry'
require 'rake/clean'

require './lib/configuration.rb'
require './lib/common.rb'
require './lib/attachments.rb'
require './lib/posts.rb'

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

namespace 'post' do
  rule /^internal\/wall[0-9]+_[0-9]+\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    owner_id, post_id = f.name.scan(/^internal\/wall([0-9]+)_([0-9]+)\.yaml$/).first.map {|elt| elt.to_i}
    target_id = "#{owner_id}_#{post_id}"

    post = @vk.wall.getById(posts: target_id)

    comments_count = @vk.wall.getComments(owner_id: owner_id, post_id: post_id, count: 1)['count']
    part_count = @config['part_count'].to_i
    pages_count = (comments_count.to_f / part_count.to_f).ceil

    comments = []
    
    (1..pages_count).each do |i|
      params = { owner_id: owner_id, post_id: post_id, sort: 'asc', count: part_count, offset: (i - 1) * part_count }

      current_comments = @vk.wall.getComments(params)['items']
      comments.push *current_comments
  
      sleep @config['sleep_time']
    end

    post.extend Hashie::Extensions::DeepFind
    comments.extend Hashie::Extensions::DeepFind

    user_ids = [ post.deep_find_all('from_id'), post.deep_find_all('user_id'), comments.deep_find_all('from_id'), comments.deep_find_all('user_id') ].flatten.uniq - [ nil ]
    profiles = get_user_profiles(user_ids)

    out_yaml = { post: post, comments: comments, profiles: profiles }.to_yaml
    File.write(f.name, out_yaml)
  end

  rule /^output\/wall[0-9]+_[0-9]+\.md$/ do |f|
    owner_id, post_id = f.name.scan(/^output\/wall([0-9]+)_([0-9]+)\.md$/).first.map { |elt| elt.to_i }
    target_id = "#{owner_id}_#{post_id}"
    input_yaml_name = "internal/wall#{target_id}.yaml"
    
    Rake::Task[:make_vk_obj].invoke
    Rake::Task[input_yaml_name].invoke

    post_hash = YAML::load(File.read(input_yaml_name))

    post = post_hash[:post].first
    comments = post_hash[:comments]
    profiles = post_hash[:profiles]

    post_md = get_post_md(post, profiles, comments)

    File.write(f.name, post_md)
  end

  rule /^internal\/wall[0-9]+\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_from_filename(f.name)
    wall_yaml = get_wall(target_id).to_yaml

    File.write(f.name, wall_yaml)
  end

  rule /^internal\/wall[0-9]+\.comments$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_from_filename(f.name)
    input_fname = "internal/wall#{target_id}.yaml"
    Rake::Task[input_fname].invoke

    posts = YAML.load(File.read(input_fname))[:posts]
    posts_filtered = posts.find_all{ |post| post['comments']['count'] > 0 }
    comments_txt = posts_filtered.map{ |post| "#{target_id}_#{post['id']}" }.join("\n")

    File.write(f.name, comments_txt)
  end

  rule /^output\/wall[0-9]+\.md$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_from_filename(f.name)
    input_fname = "internal/wall#{target_id}.yaml"
    Rake::Task[input_fname].invoke

    input = YAML.load(File.read(input_fname))
    posts = input[:posts]
    profiles = input[:profiles]

    posts_md = posts.map { |post| get_post_md(post, profiles) }.join("\n")

    File.write(f.name, posts_md)
  end

  rule /^output\/wall[0-9]+\.md.files$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_from_filename(f.name)
    wall_fname = "internal/wall#{target_id}.yaml"
    Rake::Task[wall_fname].invoke
    
    wall_hash = YAML::load(File.read(wall_fname))
    wall_hash.extend Hashie::Extensions::DeepFind

    photos = wall_hash.deep_find_all('photo').map { |photo_hash| get_photo_file(photo_hash) }
    filelist = photos.map { |photo| "#{photo[:url]}\n out=#{photo[:filename]}" }

    File.write(f.name, filelist.join("\n"))
  end

  desc "search"
  task :search, [:query, :uid, :output_fname ] do |t, args|
    Rake::Task[:make_vk_obj].invoke
    
    uid = args[:uid].to_i
    query = args[:query]

    results_count = @vk.wall.search(owner_id: uid, query: query, count: 0)['count']
    part_count = @config['part_count'].to_i
    pages_count = (results_count.to_f / part_count.to_f).ceil

    results = []
    
    (1..pages_count).each do |i|
      params = { owner_id: uid, query: query, count: part_count, offset: (i - 1) * part_count }

      current_results = @vk.wall.search(params)['items']
      results.push *current_results
  
      sleep @config['sleep_time']
    end

    urls_txt = results.map {|post| "wall#{uid}_#{post['id']}"}.join("\n")

    if args[:output_fname]
      File.open(args[:output_fname], 'w') { |f| f.puts(urls_txt) }
    else
      puts urls_txt
    end
  end
end

# desc "get wall"
# task :get_wall => 'output/wall.md'

#require './lib/messages.rb'
#require './lib/avatars.rb'

# namespace 'avatar' do
#   rule /^internal\/avatars[0-9]+\.yaml$/ do |f|
#     Rake::Task[:make_vk_obj].invoke

#     target_id = get_id_from_filename(f.name)
#     avatars_yaml = get_avatars(target_id).to_yaml
    
#     File.write(f.name, avatars_yaml)
#   end

#   rule /^internal\/avatar_likes[0-9]+\.yaml$/ do |f|
#     Rake::Task[:make_vk_obj].invoke

#     target_id = get_id_from_filename(f.name)
#     avatars_yaml_fname = "internal/avatars#{target_id}.yaml"
    
#     Rake::Task[avatars_yaml_fname].invoke
#     avatars_yaml = YAML::load(File.read(avatars_yaml_fname))[:avatars]
#     avatar_likes_yaml = get_avatar_likes(avatars_yaml).to_yaml

#     File.write(f.name, avatar_likes_yaml)
#   end

#   rule /^internal\/avatar_comments[0-9]+\.yaml$/ do |f|
#     Rake::Task[:make_vk_obj].invoke

#     target_id = get_id_from_filename(f.name)
#     avatars_yaml_fname = "internal/avatars#{target_id}.yaml"
    
#     Rake::Task[avatars_yaml_fname].invoke
#     avatars_yaml = YAML::load(File.read(avatars_yaml_fname))[:avatars]
#     avatar_comments_yaml = get_avatar_comments(avatars_yaml).to_yaml

#     File.write(f.name, avatar_comments_yaml)
#   end

#   rule /^output\/avatars[0-9]+\.md$/ do |f|
#     target_id = get_id_from_filename(f.name)
#     avatars_yaml_fname = "internal/avatars#{target_id}.yaml"
#     avatar_likes_yaml_fname = "internal/avatar_likes#{target_id}.yaml"
#     avatar_comments_yaml_fname = "internal/avatar_comments#{target_id}.yaml"
    
#     Rake::Task[:make_vk_obj].invoke
#     Rake::Task[avatars_yaml_fname].invoke
#     Rake::Task[avatar_likes_yaml_fname].invoke
#     Rake::Task[avatar_comments_yaml_fname].invoke

#     avatars_hash = YAML::load(File.read(avatars_yaml_fname))
#     avatar_likes = YAML::load(File.read(avatar_likes_yaml_fname))
#     avatar_comments = YAML::load(File.read(avatar_comments_yaml_fname))

#     avatars = avatars_hash[:avatars]
#     filelist = avatars_hash[:filelist]
    
#     avatars_md = avatars.map do |avatar|
#       get_avatar_md(avatar, avatar_likes, avatar_comments, filelist)
#     end.join("\n")

#     File.write(f.name, avatars_md)
#   end

#   rule /^output\/avatars[0-9]+\.md.files$/ do |f|
#     target_id = get_id_from_filename(f.name)
#     avatars_yaml_fname = "internal/avatars#{target_id}.yaml"
     
#     Rake::Task[:make_vk_obj].invoke
#     Rake::Task[avatars_yaml_fname].invoke
    
#     avatars_hash = YAML::load(File.read(avatars_yaml_fname))
    
#     avatars = avatars_hash[:avatars]
#     filelist = avatars_hash[:filelist]
#     avatars_md_files = avatars.map { |avatar| get_avatar_files(avatar, filelist) }.join("\n")

#     File.write(f.name, avatars_md_files)
#   end
# end

# namespace 'msg' do
#   desc "get conversation list"
#   task :get_conversation_list, :output_filename do |f, args|
#     input_filename = 'internal/conversations.yaml'

#     Rake::Task[input_filename].invoke  
#     conversations = YAML::load(File.read(input_filename))
#     conversations_txt = get_conversation_list_txt(conversations)

#     if args[:output_filename]
#       File.open(args[:output_filename], 'w') { |f| f.puts(conversations_txt) }
#     else
#       puts conversations_txt
#     end
#   end

#   desc "get conversations in md"
#   task :get_conversations_in_md, :name do |f, args|
#     abort 'Specify filename!' unless args[:name]

#     input = File.read(args[:name])  
#     user_ids = get_conversation_user_ids(input)
    
#     puts "User IDs: #{user_ids.join(', ')}"

#     user_ids.each do |target_id|
#       puts "processing: #{target_id}"
#       Rake::Task["output/msg#{target_id}.md"].invoke
#     end
#   end

#   rule /^internal\/conversations\.yaml$/ do |f|
#     Rake::Task[:make_vk_obj].invoke

#     conversations = get_conversation_list
#     File.write(f.name, YAML::dump(conversations))
#   end

#   rule /^internal\/msg([0-9]+)\.yaml$/ do |f|
#     Rake::Task[:make_vk_obj].invoke

#     target_id = get_id_from_filename(f.name)
#     messages = get_messages(target_id).to_yaml
#     File.write(f.name, messages)
#   end

#   rule /^output\/msg([0-9]+)\.md$/ => [ 
#     proc {|name| "internal/msg#{get_id_from_filename(name)}.yaml" }
#   ] do |f|
#     target_id = get_id_from_filename(f.name)
    
#     input_name = "internal/msg#{target_id}.yaml"
#     messages_yaml = YAML::load(File.read(input_name))
#     messages_md = msg_yaml_to_md(messages_yaml)

#     File.write(f.name, messages_md)
#   end
# end
