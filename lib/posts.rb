def get_post_txt(post)
  header = get_post_header_txt(post)
  body = get_post_body_txt(post)
  footer = get_post_footer_txt(post)

  header + "\n" + body + "\n" + footer
end

def get_post_header_txt(post)
  time = Time.at(post['date']).strftime(@config['time_format'])
  author = post['from_id']

  "[#{time} #{author}]:"
end

def get_post_body_txt(post)
  body = post['text']

  return '<empty body>' if body.to_s.empty?

  body
end

def get_post_footer_txt(post)
  likes_count = post['likes']['count']
  reposts_count = post['reposts']['count']

  "-- Likes: #{likes_count}, Reposts: #{reposts_count} --"
end