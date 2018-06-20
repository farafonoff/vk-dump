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


def get_conversation_user_ids(input)
  input.split(/\n/).map { |elt| elt.scan(/([0-9]+) .*/).first.first.to_i }
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
  messages_yaml.reverse_each.map { |msg| msg_get_txt(msg) }.join("\n")
end

def msg_get_txt(msg)
  header = msg_get_header_txt(msg)
  body = msg_get_body_txt(msg)

  result = header + "\n" + body + "\n"

  if msg['fwd_messages']
    result += ":::: Forwarded messages (#{msg['fwd_messages'].count}) ::::\n"
    result += text_indent(msg_get_forwarded_txt(msg))
  end

  if msg['attachments']
    result += ":::: Attachments (#{msg['attachments'].count}) ::::\n"
    result += text_indent(msg_get_attachments_txt(msg))
  end

  result
end

def msg_get_body_txt(msg)
  return '<empty message>' if msg['body'].empty?

  msg['body']
end

def msg_get_header_txt(msg)
  time = Time.at(msg['date'])
  sender = msg['from_id'] || msg['user_id']

  "[#{time} #{sender}]:"
end

def msg_get_forwarded_txt(msg)
  msg_strings = msg['fwd_messages'].map do |inner_msg|
    msg_get_txt(inner_msg)
  end

  msg_strings.join("\n")
end

def msg_get_attachments_txt(msg)
  attachment_strings = msg['attachments'].map do |attachment|
    get_attachment_txt(attachment)
  end

  attachment_strings.join("\n")
end