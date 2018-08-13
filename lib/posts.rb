def get_wall_hash(target_id = 0)
  params = { owner_id: target_id, sort: 'asc' }

  posts = multiple_requests(params) { |params_hash| @vk.wall.get(params_hash) }

  posts
end

def get_post_hash(owner_id, post_id)
  target_id = "#{owner_id}_#{post_id}"
  post = @vk.wall.getById(posts: target_id)

  params = { owner_id: owner_id, post_id: post_id, sort: 'asc' }
  comments = multiple_requests(params) { |params_hash| @vk.wall.getComments(params_hash) }

  out = { post: post, comments: comments }
  
  out
end

def get_wall_md(posts, names)
  posts_md = posts.map { |post| get_post_md(post, names) }.join("\n")

  posts_md
end

def get_post_file_md(post_hash, names)
  post = post_hash[:post].first
  comments = post_hash[:comments]

  post_md = get_post_md(post, names, comments)

  post_md
end

def get_post_md(post, names, comments = nil)
  header = get_post_header_md(post, names)
  body = get_post_body_md(post)

  result = header + "\n" + body + "  \n"

  footer = get_post_footer_md(post)
  result += (footer + "  \n") if footer

  if post['attachments']
    result += "_Attachments (#{post['attachments'].count}):_  \n\n"
    result += text_indent(get_post_attachments_md(post, names)) + "\n\n"
  end

  if post['copy_history']
    result += "_Reposted (#{post['copy_history'].count}):_  \n\n"
    result += text_indent(get_post_copy_history_md(post, names)) + "\n\n"
  end

  if comments
    result += "_Comments (#{comments.count}):_  \n\n"
    result += text_indent(get_post_comments_md(comments, names))
  end

  result
end

def get_post_comments_md(comments, names)
  comments_md = comments.map do |comment|
    get_post_md(comment, names)
  end.join("\n")

  comments_md
end

def get_post_header_md(post, names)
  time = get_time_txt(post['date'])
  id = post['from_id'] || post['user_id']
  author = names[id]

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
  result.push "Comments: #{post['comments']['count']}" if post['comments']

  return nil if result.empty?

  "_#{result.join(', ')}_"
end

def get_post_attachments_md(post, names)
  attachment_strings = post['attachments'].map do |attachment|
    get_attachment_md(attachment, names)
  end

  attachment_strings.join("  \n")
end

def get_post_copy_history_md(post, names)
  posts_md = post['copy_history'].map { |post| get_post_md(post, names) }.join("\n")

  posts_md
end

# def wall_search(uid, query)
#   params = { owner_id: uid, query: query }

#   results = multiple_requests(params) { |params_hash| @vk.wall.search(params_hash) }
#   urls_list = results.map {|post| "wall#{uid}_#{post['id']}"}

#   urls_list
# end

# def get_posts_wcomments_list(posts) 
#   posts_filtered = posts[:posts].find_all{ |post| post['comments']['count'] > 0 }

#   posts_list = posts_filtered.map do |post|
#     id = post['id']
#     owner_id = post['owner_id']
  
#     "#{owner_id}_#{id}"
#   end

#   posts_list
# end
