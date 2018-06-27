def get_wall
  posts_count = @vk.wall.get(count: 1, v: API_VERSION)['count']
  part_count = @config['part_count'].to_i
  pages_count = (posts_count.to_f / part_count.to_f).ceil

  posts = []
  (1..pages_count).each do |i|
    params = { count: @config['part_count'], offset: (i - 1) * @config['part_count'], v: API_VERSION }
    current_posts = @vk.wall.get(params)['items']
    posts.push *current_posts

    sleep @config['sleep_time']
  end

  posts.extend Hashie::Extensions::DeepFind

  from_ids = posts.deep_find_all('from_id')
  user_ids = posts.deep_find_all('user_id')
  owner_ids = posts.deep_find_all('owner_id')
  uids = (from_ids + user_ids + owner_ids).find_all { |elt| elt > 0 }.uniq

  profiles = get_user_profiles(uids)

  { :posts => posts, :profiles => profiles }
end

def get_post_md(post, profiles)
  header = get_post_header_md(post, profiles)
  body = get_post_body_md(post)

  result = header + "\n" + body + "  \n"

  footer = get_post_footer_md(post)
  result += (footer + "  \n") if footer

  if post['attachments']
    result += "_Attachments (#{post['attachments'].count}):_  \n"
    result += text_indent(get_post_attachments_md(post, profiles)) + "\n\n"
  end

  if post['copy_history']
    result += "_Reposted (#{post['copy_history'].count}):_  \n"
    result += text_indent(get_post_copy_history_md(post, profiles))
  end

  # if post['comments']
  #   result += "_Comments (#{post['comments']['count'].to_i}):_  \n"
  # end

  result
end

def get_post_header_md(post, profiles)
  time = get_time_txt(post['date'])
  id = post['from_id'] || post['user_id']
  author = profiles[id]

  return "\#\# ID: #{id} (#{time}):" unless author

  "\#\# #{author} (#{time}):"
end

def get_post_body_md(post)
  body = post['text']

  return '`empty body`' if body.empty?
  body.gsub(/\n/, "  \n").gsub(/#/, '\#')
end

def get_post_footer_md(post)
  result = []

  result.push "Likes: #{post['likes']['count']}" if post['likes']
  result.push "Reposts: #{post['reposts']['count']}" if post['reposts']

  return nil if result.empty?

  "_#{result.join(', ')}_"
end

def get_post_attachments_md(post, profiles)
  attachment_strings = post['attachments'].map do |attachment|
    get_attachment_md(attachment)
  end

  attachment_strings.join("  \n")
end

def get_post_copy_history_md(post, profiles)
  posts_md = post['copy_history'].map { |post| get_post_md(post, profiles) }.join("\n")

  posts_md
end