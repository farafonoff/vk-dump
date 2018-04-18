def get_prefix(level)
  @config['prefix_string'] * level
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
  # TODO: сделать обработку вложений у постов

  prefix = get_prefix(level)
  next_prefix = get_prefix(level + 1)

  text = prefix_multiline(post['text'], next_prefix)
  date = Time.at(post['date'])
  author = post['from_id']

  if (post['post_type'] == 'post')
    pre_header = "#{prefix}Вложение (пост):\n"
  else
    pre_header = "#{prefix}Вложение (ответ на пост):\n"
  end

  header = "#{next_prefix}[#{date} #{author}]:\n"
  
  pre_header + header + text
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
      "#{prefix}Вложение (другое). FIXME: необработанный тип вложений!"
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