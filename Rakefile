require 'vkontakte_api'
require 'yaml'
require 'pry'
require 'kramdown'
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

    id_params = get_id_params(f.name)
    out_yaml = get_post_hash(id_params[:owner_id], id_params[:id]).to_yaml

    File.write(f.name, out_yaml)
  end

  rule /^internal\/wall[0-9]+\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_params(f.name)[:id]
    wall_yaml = get_wall_hash(target_id).to_yaml

    File.write(f.name, wall_yaml)
  end

  rule /^internal\/.+\.names\.yaml$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    source_filename = f.name.sub(/\.names\.yaml$/,'.yaml')
    Rake::Task[source_filename].invoke

    source_hash = YAML.load(File.read(source_filename))
    names_hash = get_names_hash(source_hash)

    File.write(f.name, names_hash.to_yaml)
  end

  rule /^output\/wall[0-9]+\.md$/ do |f|
    Rake::Task[:make_vk_obj].invoke

    target_id = get_id_params(f.name)[:id]

    wall_yaml_filename = "internal/wall#{target_id}.yaml"
    names_yaml_filename = "internal/wall#{target_id}.names.yaml"

    Rake::Task[wall_yaml_filename].invoke
    Rake::Task[names_yaml_filename].invoke

    posts = YAML.load(File.read(wall_yaml_filename))
    names = YAML.load(File.read(names_yaml_filename))

    posts_md = get_wall_md(posts, names)

    File.write(f.name, posts_md)
  end

  rule /^output\/wall[0-9]+_[0-9]+\.md$/ do |f|
    target_str = get_id_params(f.name)[:target_str]
    post_yaml_filename = "internal/wall#{target_str}.yaml"
    names_yaml_filename = "internal/wall#{target_str}.names.yaml"

    Rake::Task[:make_vk_obj].invoke
    Rake::Task[post_yaml_filename].invoke
    Rake::Task[names_yaml_filename].invoke

    post = YAML::load(File.read(post_yaml_filename))
    names = YAML.load(File.read(names_yaml_filename))

    post_md = get_post_file_md(post, names)

    File.write(f.name, post_md)
  end
end

  # rule /^internal\/wall[0-9]+\.comments$/ do |f|
  #     Rake::Task[:make_vk_obj].invoke
  
  #     target_id = get_id_params(f.name)[:id]
  #     input_fname = "internal/wall#{target_id}.yaml"
  #     Rake::Task[input_fname].invoke
  
  #     posts = YAML.load(File.read(input_fname))
  #     comments_txt = get_posts_wcomments_list(posts).join("\n")
  
  #     File.write(f.name, comments_txt)
  #   end
  
 
  #   rule /^output\/wall[0-9]+\.html$/ do |f|
  #     Rake::Task[:make_vk_obj].invoke
  
  #     target_id = get_id_params(f.name)[:id]
  #     input_fname = "output/wall#{target_id}.md"
  #     Rake::Task[input_fname].invoke
      
  #     txt = File.read(input_fname)
  #     md = Kramdown::Document.new(txt)
      
  #     html = "<!DOCTYPE html>
  # <html>
  # <head>
  # <meta charset=\"utf-8\">
  # <title>Стена</title>
  # </head>
  # <body>" + md.to_html + "</body>
  # </html>"
  
  #     File.write(f.name, html)
  #   end
  
  #   rule /^output\/wall[0-9_]+\.files$/ do |f|
  #     Rake::Task[:make_vk_obj].invoke
  
  #     target_str = get_id_params(f.name)[:target_str]
  #     wall_fname = "internal/wall#{target_str}.yaml"
  #     Rake::Task[wall_fname].invoke
      
  #     wall_hash = YAML::load(File.read(wall_fname))
  #     filelist_txt = get_hash_filelist(wall_hash).join("\n")
  
  #     File.write(f.name, filelist_txt) if filelist_txt.length > 0
  #   end
  
  #   desc "search"
  #   task :search, [:query, :uid, :output_fname ] do |t, args|
  #     Rake::Task[:make_vk_obj].invoke
      
  #     uid = args[:uid].to_i
  #     query = args[:query]
  
  #     urls_txt = wall_search(uid, query).join("\n")
  
  #     if args[:output_fname]
  #       File.open(args[:output_fname], 'w') { |f| f.puts(urls_txt) }
  #     else
  #       puts urls_txt
  #     end
  #   end
  

# desc "get wall"
# task :get_wall => 'output/wall.md'

#require './lib/messages.rb'

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
