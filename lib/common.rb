def get_user_profiles(ids)
  raise 'USERS > 1000: not implemented' if ids.count > 1000

  users = @vk.users.get(user_ids: ids)

  out = {}
  users.each do |elt|
    id = elt[:id]
    username = "#{elt[:first_name]} #{elt[:last_name]}"

    out[id] = username
  end

  out
end

def get_token(url)
  url.scan(/access_token=([^&]+)/).first.first
end

def get_id_from_filename(str)
  str.scan(/[0-9]+/).first.to_i
end

def text_indent(text)
  prefix = @config['prefix_string']
  text.each_line.map { |line| prefix + line }.join
end

def get_time_txt(time)
  res = Time.at(time).strftime(@config['time_format'])

  res
end