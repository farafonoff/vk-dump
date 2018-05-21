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

def get_messages(target_id)
  messages_count = @vk.messages.getHistory(user_id: target_id, count: 0)['count']
  part_count = @config['part_count']
  messages_parts = (messages_count.to_f / part_count.ceil)
  
  messages = (0...messages_parts).reduce([]) do |result,i|
    messages_part = @vk.messages.getHistory(user_id: target_id, count: @config['part_count'], offset: i * @config['part_count'])['items']
    sleep @config['sleep_time']
    result += messages_part
  end
end

def msg_yaml_to_txt(messages_yaml)
  messages_yaml.reverse_each.map { |msg| get_msg_txt(msg) }.join("\n")
end

def get_user_ids(input)
  input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }
end

def get_token(url)
  url.scan(/access_token=([^&]+)/).first.first
end

def get_conversation_list
  dialog_count = @vk.messages.getDialogs(count: 0)['count']
  part_count = @config['part_count']
  dialog_parts = (dialog_count.to_f / part_count).ceil
  
  strs = (0...dialog_parts).map do |i|
    dialog_params = { preview_length: 1, count: @config['part_count'], offset: i * @config['part_count'] }
    current_ids_part = @vk.messages.getDialogs(dialog_params)['items'].map {|elt| elt['message']['user_id'] }
    users_part = @vk.users.get(user_ids: current_ids_part)

    sleep @config['sleep_time']

    users_part.map { |user| "#{user[:id]} \# #{user[:first_name]} #{user[:last_name]}" }
  end.flatten
end

def get_index(str)
  str.scan(/[0-9]+/).first.to_i
end

def make_header(post)
  time = Time.at(post['date']).strftime(@config['time_format'])

  "[#{time} #{post['from_id']}]:"
end

def make_footer(post)
  likes_count = post['likes']['count']
  reposts_count = post['reposts']['count']

  "-- Likes: #{likes_count}, Reposts: #{reposts_count} --"
end

def make_post(post)
  if post['attachments']
    attachments_count = post['attachments'].count
    attachments = "-- Attachments: #{attachments_count} --"

    return [ make_header(post), post['text'], attachments, make_footer(post) ].join("\n")
  end

  [ make_header(post), post['text'], make_footer(post) ].join("\n")
end