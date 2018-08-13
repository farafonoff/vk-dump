def get_token(url)
  url.scan(/access_token=([^&]+)/).first.first
end

def multiple_requests(params)
  count_params = params.merge({ count: 1})
  
  results_count = yield(count_params)['count']
  part_count = @config['part_count'].to_i
  pages_count = (results_count.to_f / part_count.to_f).ceil

  results = []
  (1..pages_count).each do |i|
    current_params = params.merge({ count: part_count, offset: (i - 1) * part_count })
    current_results = yield(current_params)['items']
    results.push *current_results

    sleep @config['sleep_time']
  end

  results
end

def get_id_params(filename)
  results = filename.scan(/(?:([0-9]+)_)?([0-9]+)/).first

  id = results[1].to_i

  if results[0]
    owner_id = results[0].to_i
    target_str = "#{owner_id}_#{id}"
  else
    owner_id = nil
    target_str = id.to_s
  end

  result = { target_str: target_str, owner_id: owner_id, id: id }

  result
end

def get_uids(sources)
  sources_extended = sources.map { |source| source.dup.extend Hashie::Extensions::DeepFind }

  raw_ids = []
  sources_extended.each do |source_extended|
    from_ids = source_extended.deep_find_all('from_id')
    user_ids = source_extended.deep_find_all('user_id')
    owner_ids = source_extended.deep_find_all('owner_id')

    raw_ids.push *([ from_ids, user_ids, owner_ids ].flatten)
  end
  
  uids = raw_ids.find_all { |elt| elt.to_i > 0 }.uniq

  uids
end

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

def text_indent(text)
  prefix = @config['prefix_string']
  text.each_line.map { |line| prefix + line }.join
end

def get_time_txt(time)
  res = Time.at(time).strftime(@config['time_format'])

  res
end