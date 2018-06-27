def get_attachment_md(attachment)
  case attachment['type']
  when 'photo'
    url = get_best_photo_url(attachment['photo'])
    
    #return "![image](#{url})"
    return "*image:* [image](#{url})"
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
  # when 'wall'
  #   post_txt = get_post_txt(attachment['wall'])

  #   return post_txt
  else
    return '*unknown type*'
  end
end
