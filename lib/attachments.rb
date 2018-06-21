def get_attachment_txt(attachment)
  case attachment['type']
  when 'photo'
    url = get_best_photo_url(attachment['photo'])
    
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

    return "doc: #{url} (#{title})"
  when 'wall'
    post_txt = get_post_txt(attachment['wall'])

    return post_txt
  else
    return 'unknown type'
  end
end
