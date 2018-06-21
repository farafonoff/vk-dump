def get_post_txt(post)
  id = post['id'].to_i

  header = get_post_header_txt(post)
  body = get_post_body_txt(post)
  result = header + "\n" + body + "\n"

  footer = get_post_footer_txt(post)
  result += (footer + "\n") if footer

  if post['attachments']
    result += "--- Attachments (#{post['attachments'].count}) ---\n"
    result += text_indent(get_post_attachments_txt(post)) + "\n"
  end

  if post['copy_history']
    result += "--- Reposted (#{post['copy_history'].count}) ---\n"
    result += text_indent(get_post_copy_history_txt(post))
  end

  if post['comments']
    comments_count = post['comments']['count'].to_i
    result += "--- Comments: #{comments_count} ---\n"

    if (comments_count > 0)
      comments_hashes = @vk.wall.getComments(post_id: id)['items']
      comments_txts = comments_hashes.map { |comment_hash| get_post_txt(comment_hash) }
      comments_txt = comments_txts.join("\n")

      result += text_indent(comments_txt)

      sleep @config['sleep_time']
    end
  end

  result
end

def get_post_header_txt(post)
  time = get_time_txt(post['date'])
  author = post['from_id']

  "[#{time} #{author}]:"
end

def get_post_body_txt(post)
  body = post['text']

  return '<empty body>' if body.to_s.empty?

  body
end

def get_post_footer_txt(post)
  result = []

  result.push "Likes: #{post['likes']['count']}" if post['likes']
  result.push "Reposts: #{post['reposts']['count']}" if post['reposts']
  result.push "Views: #{post['views']['count']}" if post['views']

  return nil if result.empty?

  "--- #{result.join(', ')} ---"
end

def get_post_attachments_txt(post)
  attachment_strings = post['attachments'].map do |attachment|
    get_attachment_txt(attachment)
  end

  attachment_strings.join("\n")
end

def get_post_copy_history_txt(post)
  posts_txt = post['copy_history'].map { |post| get_post_txt(post) }.join("\n")

  posts_txt
end