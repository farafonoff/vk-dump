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
  user_ids = users_hashes.map { |hsh| hsh[:peer][:id] }
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

# def get_conversation_user_ids(input)
#   input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }
# end

# def get_messages(target_id)
#   messages_count = @vk.messages.getHistory(user_id: target_id, count: 0)['count']
#   part_count = @config['part_count']
#   messages_parts = (messages_count.to_f / part_count.ceil)
  
#   messages = (0...messages_parts).reduce([]) do |result,i|
#     messages_part = @vk.messages.getHistory(user_id: target_id, count: @config['part_count'], offset: i * @config['part_count'])['items']
#     sleep @config['sleep_time']
#     result += messages_part
#   end
# end

# def msg_yaml_to_txt(messages_yaml)
#   messages_yaml.reverse_each.map { |msg| msg_get_txt(msg) }.join("\n")
# end

# def msg_get_txt(msg)
#   header = msg_get_header_txt(msg)
#   body = msg_get_body_txt(msg)

#   result = header + "\n" + body + "\n"

#   if msg['fwd_messages']
#     result += ":::: Forwarded messages (#{msg['fwd_messages'].count}) ::::\n"
#     result += text_indent(msg_get_forwarded_txt(msg))
#   end

#   if msg['attachments']
#     result += ":::: Attachments (#{msg['attachments'].count}) ::::\n"
#     result += text_indent(msg_get_attachments_txt(msg)) + "\n"
#   end

#   result
# end

# def msg_get_body_txt(msg)
#   return '<empty message>' if msg['body'].empty?

#   msg['body']
# end

# def msg_get_header_txt(msg)
#   time = get_time_txt(msg['date'])
#   sender = msg['from_id'] || msg['user_id']

#   "[#{time} #{sender}]:"
# end

# def msg_get_forwarded_txt(msg)
#   msg_strings = msg['fwd_messages'].map do |inner_msg|
#     msg_get_txt(inner_msg)
#   end

#   msg_strings.join("\n")
# end

# def msg_get_attachments_txt(msg)
#   attachment_strings = msg['attachments'].map do |attachment|
#     get_attachment_txt(attachment)
#   end

#   attachment_strings.join("\n")
# end