def get_wall(target_id = 0)
  params = { owner_id: target_id, sort: 'asc' }
  posts = multiple_requests(params) { |params_hash| @vk.wall.get(params_hash) }

  posts.extend Hashie::Extensions::DeepFind

  from_ids = posts.deep_find_all('from_id')
  user_ids = posts.deep_find_all('user_id')
  owner_ids = posts.deep_find_all('owner_id')
  uids = [ from_ids, user_ids, owner_ids ].flatten.find_all { |elt| elt.to_i > 0 }.uniq

  profiles = get_user_profiles(uids)

  { :posts => posts, :profiles => profiles }
end

def get_post_md(post, profiles, comments = nil)
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
    result += text_indent(get_post_copy_history_md(post, profiles)) + "\n\n"
  end

  if comments
    result += "_Comments (#{comments.count}):_  \n"
    result += text_indent(get_post_comments_md(comments, profiles))
  end

  result
end

def get_post_comments_md(comments, profiles)
  comments_md = comments.map do |comment|
    get_post_md(comment, profiles)
  end.join("\n")

  comments_md
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
    get_attachment_md(attachment, profiles)
  end

  attachment_strings.join("  \n")
end

def get_post_copy_history_md(post, profiles)
  posts_md = post['copy_history'].map { |post| get_post_md(post, profiles) }.join("\n")

  posts_md
end