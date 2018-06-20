def get_attachment_txt(attachment)
  case attachment['type']
  when 'photo'
    url = get_attachment_photo_url(attachment['photo'])
    
    return "image: #{url}"
  when 'link'
    url = attachment['link']['url']
    title = attachment['link']['title']
    
    return "link: #{url} (#{title})"
  when 'audio'
    artist = attachment['audio']['artist']
    title = attachment['audio']['title']
      
    return "audio: #{artist} - #{title}"
  when 'video'
    title = attachment['video']['title']

    return "video: #{title}"
  when 'doc'
    url = attachment['doc']['url'] 
    title = attachment['doc']['title']

    "doc: #{url} (#{title})"
  else
    return 'unknown type'
  end
end

def get_attachment_photo_url(photos)
  resolution_strings = photos.keys.find_all {|str| str.include? 'photo_'}
  max_res = resolution_strings.map {|str| str.scan(/photo_([0-9]+)/).first.first.to_i }.max
  photo_url = photos["photo_#{max_res}"]

  "#{photo_url}"
end
