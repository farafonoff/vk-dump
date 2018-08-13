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

def get_ugids_from_hash(source)
  source_extended = source.dup.extend Hashie::Extensions::DeepFind

  from_ids = source_extended.deep_find_all('from_id') || []
  user_ids = source_extended.deep_find_all('user_id') || []
  owner_ids = source_extended.deep_find_all('owner_id') || []

  ids = [ from_ids, user_ids, owner_ids ].flatten.uniq
  results = ids.group_by{ |elt| elt < 0 }

  { uids: results[false], gids: results[true] }
end

def get_names_hash(source_hash)
  ugids = get_ugids_from_hash(source_hash)

  users_hash = get_users_hash(ugids[:uids] || [])
  groups_hash = get_groups_hash(ugids[:gids] || [])
  result_hash = users_hash.merge(groups_hash)

  result_hash
end

def get_users_hash(uids)
  users_arr = []
  
  uids.each_slice(@config['users_part_count']) do |uids_slice|
    current_users = @vk.users.get(user_ids: uids_slice)

    current_users_arr = current_users.map do |hsh|
      [ hsh[:id], "#{hsh[:first_name]} #{hsh[:last_name]}"]
    end

    users_arr.push *current_users_arr

    sleep @config['sleep_time']
  end
  
  users_hash = users_arr.to_h

  users_hash
end

def get_groups_hash(gids)
  groups_arr = []
  
  gids.map{ |elt| -elt }.each_slice(@config['groups_part_count']) do |gids_slice|
    current_groups = @vk.groups.getById(group_ids: gids_slice)

    current_groups_arr = current_groups.map do |hsh|
      [ -hsh[:id], "#{hsh[:name]} (group)" ]
    end

    groups_arr.push *current_groups_arr

    sleep @config['sleep_time']
  end
  
  groups_hash = groups_arr.to_h

  groups_hash
end


# def text_indent(text)
#   prefix = @config['prefix_string']
#   text.each_line.map { |line| prefix + line }.join
# end

# def get_time_txt(time)
#   res = Time.at(time).strftime(@config['time_format'])

#   res
# end