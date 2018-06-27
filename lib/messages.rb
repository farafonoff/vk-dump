def get_conversation_list
  conversations_count = @vk.messages.getConversations(count: 0)[:count]
  part_count = @config['part_count'].to_i
  conversation_parts_count = (conversations_count.to_f / part_count.to_f).ceil

  conversation_parts = (1..conversation_parts_count).map do |i|
    sleep @config['sleep_time']

    params = { preview_length: 0, count: part_count, offset: ( i - 1 ) * part_count }
    conversations_part = @vk.messages.getConversations(params)['items'].map do |part|
      part[:conversation]
    end

    conversations_part
  end
  
  conversations = conversation_parts.flatten

  users_hashes = conversations.find_all { |conv| conv[:peer][:type] == 'user' }
  user_ids = users_hashes.map { |hsh| hsh[:peer][:id] }.uniq
  user_profiles = get_user_profiles(user_ids)

  { conversations: conversations, profiles: user_profiles }
end

def get_conversation_list_txt(hashes)
  conversations = hashes[:conversations]
  profiles = hashes[:profiles]

  results = conversations.map do |hsh| 
    id = hsh[:peer][:id]
    type = hsh[:peer][:type]
    
    if type == 'user'
      "#{id} \# #{type}: #{profiles[id]}"
    else
      "#{id} \# #{type}"
    end
  end

  results.join("\n")
end

def get_messages(target_id)
  messages_count = @vk.messages.getHistory(user_id: target_id, count: 0)['count']
  part_count = @config['part_count']
  messages_parts_count = (messages_count.to_f / part_count.to_f).ceil
  
  messages = (1..messages_parts_count).reduce([]) do |result, i|
    sleep @config['sleep_time']

    params = { user_id: target_id, count: @config['part_count'], offset: (i - 1) * @config['part_count'] }
    messages_part = @vk.messages.getHistory(params)['items']
    
    result += messages_part
  end

  messages.extend Hashie::Extensions::DeepFind

  user_ids_deep_found = messages.deep_find_all('from_id') + messages.deep_find_all('user_id')
  user_ids = (user_ids_deep_found || nil).uniq
  user_profiles = get_user_profiles(user_ids)

  { messages: messages, profiles: user_profiles }
end

def msg_yaml_to_md(messages_yaml)
  messages = messages_yaml[:messages]
  profiles = messages_yaml[:profiles]

  messages_md = messages.reverse_each.map do |msg|
    msg_get_md(msg, profiles)
  end

  messages_md.join("\n")
end

def msg_get_md(msg, profiles)
  header = msg_get_header_md(msg, profiles)
  body = msg_get_body_md(msg)

  result = header + "  \n" + body + "  \n"

  if msg['fwd_messages']
    result += "_Forwarded messages (#{msg['fwd_messages'].count}):_  \n"
    result += text_indent(msg_get_forwarded_md(msg, profiles))
  end

  if msg['attachments']
    result += "_Attachments (#{msg['attachments'].count}):_  \n"
    result += text_indent(msg_get_attachments_md(msg)) + "\n"
  end

  result
end

def msg_get_header_md(msg, profiles)
  time = get_time_txt(msg['date'])
  username = profiles[msg[:from_id] || msg[:user_id]]

  "\#\# #{username} *(#{time})*"
end

def msg_get_body_md(msg)
  return '`empty message`' if msg['body'].empty?

  msg['body'].gsub(/\n/, "  \n").gsub(/#/, '\#')
end

def msg_get_forwarded_md(msg, profiles)
  msg_strings = msg['fwd_messages'].map do |inner_msg|
    msg_get_md(inner_msg, profiles)
  end

  msg_strings.join("\n")
end

def msg_get_attachments_md(msg)
  attachment_strings = msg['attachments'].map do |attachment|
    get_attachment_md(attachment)
  end

  attachment_strings.join("  \n")
end

def get_conversation_user_ids(input)
  ids = input.scan(/([0-9]+) \# user/).map do |elt|
    elt.first.to_i
  end

  ids
end
