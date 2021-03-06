def get_hash_filelist(target_hash)
  target_hash_dup = target_hash.dup
  target_hash_dup.extend Hashie::Extensions::DeepFind

  filelist = []

  photos = (target_hash_dup.deep_find_all('photo') || []).map { |photo_hash| get_photo_file(photo_hash) }
  filelist += photos.map { |photo| "#{photo[:url]}\n out=#{photo[:filename]}" }

  graffities = (target_hash_dup.deep_find_all('graffiti') || []).map { |graffiti_hash| get_graffiti_file(graffiti_hash) }
  filelist += graffities.map { |graffiti| "#{graffiti[:url]}\n out=#{graffiti[:filename]}" }

  filelist
end

def get_best_photo_url(photos)
  resolution_strings = photos.keys.find_all { |str| str.include? 'photo_' }
  resolutions = resolution_strings.map { |str| str.scan(/photo_([0-9]+)/).first.first.to_i }
  photo_url = photos["photo_#{resolutions.max}"]

  "#{photo_url}"
end

def get_photo_file(photo)
  url = get_best_photo_url(photo)
  ext = File::extname(url)
  owner_id = photo['owner_id'].to_i
  id = photo['id'].to_i

  filename = "#{owner_id}_#{id}#{ext}"

  return { filename: filename, url: url }
end

def get_graffiti_file(graffiti)
  res_hash = get_photo_file(graffiti)
  res_hash[:filename] = 'g' + res_hash[:filename]

  res_hash
end

def get_attachment_md(attachment, profiles)
  case attachment['type']
  when 'photo'
    filename = get_photo_file(attachment['photo'])[:filename]
    
    return "\![#{filename}](#{filename})"
  when 'link'
    url = attachment['link']['url']
    title = attachment['link']['title']
    
    return "*link:* [#{title}](#{url})"
  when 'audio'
    artist = attachment['audio']['artist']
    title = attachment['audio']['title']
      
    return "*audio:* __#{artist} - #{title}__"
  when 'video'
    title = attachment['video']['title']

    return "*video:* __#{title}__"
  when 'doc'
    url = attachment['doc']['url'] 
    title = attachment['doc']['title']

    return "*doc:* [#{title}](#{url})"
  when 'wall'
    post_md = get_post_md(attachment['wall'], profiles)

    return post_md
  when 'poll'
    poll = attachment['poll']
    question = poll['question']
    answers = poll['answers'].map { |answer| "- #{answer['text']}: #{answer['votes']}" }
    
    return "*poll:* **#{question}**\n\n#{answers.join("\n")}"
  when 'graffiti'
    graffiti = attachment['graffiti']
    filename = get_graffiti_file(graffiti)[:filename]
    
    return "\![#{filename}](#{filename})"
  when 'note'
    note = attachment['note']
    title = note['title']

    return "*note:* **#{title}**"
  else
    return "*unknown type:* #{attachment['type']}"
  end
end
