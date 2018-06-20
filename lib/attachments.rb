# def get_photo_url(attachment)
#   resolution_strings = attachment['photo'].keys.find_all {|str| str.include? 'photo_'}
#   max_res = resolution_strings.map {|str| str.scan(/photo_([0-9]+)/).first.first.to_i }.max
#   photo_url = attachment['photo']["photo_#{max_res}"]

#   "#{photo_url}"
# end

# # def process_attachment(attachment)
# #   case attachment['type']
# #   when 'photo'
# #     url = get_photo_url(attachment)
    
# #     return "img: #{url}"
# #   when 'link'
# #     url = attachment['link']['url']
# #     title = attachment['link']['title']
    
# #     return "link: #{url} (#{title})"
# #   when 'audio'
# #     artist = attachment['audio']['artist']
# #     title = attachment['audio']['title']
      
# #     return "audio: #{artist} - #{title}"
# #   when 'video'
# #     title = attachment['video']['title']

# #     return "video: #{title}"
# #   when 'doc'
# #     url = attachment['doc']['url'] 
# #     title = attachment['doc']['title']

# #     "doc: #{url} (#{title})"
# #   else
# #     return 'unknown type'
# #   end
# # end

# # def process_attachments(post)
# #   attachments_count = post['attachments'].count
  
# #   attachments_txt = post['attachments'].map do |curr|
# #     process_attachment(curr)
# #   end.join("\n")

# #   "-- Attachments: #{attachments_count} --" + "\n" + attachments_txt
# # end

# # def make_post(post)
# #   if post['attachments']
# #     attachments = process_attachments(post, 1)
    
# #     return [ make_header(post), post['text'], attachments, make_footer(post) ].join("\n")
# #   end

# #   [ make_header(post), post['text'], make_footer(post) ].join("\n")
# # end


# def process_attachments(msg, level)
#   prefix = get_prefix(level)

#   return '' unless msg['attachments']

#   result = msg.attachments.map do |attachment|
#     case attachment['type']
#     when 'photo'
#       url = get_photo_url(attachment)

#       "#{prefix}Вложение (фото): #{url}"
#     when 'link'
#       url = attachment['link']['url']
#       title = attachment['link']['title']

#       "#{prefix}Вложение (ссылка): #{title} (#{url})"
#     when 'audio'
#       artist = attachment['audio']['artist']
#       title = attachment['audio']['title']

#       "#{prefix}Вложение (аудио): #{artist} - #{title}"
#     when 'video'
#       title = attachment['video']['title']

#       "#{prefix}Вложение (видео): #{title}"
#     when 'wall'
#       get_wall_post(attachment['wall'], level)
#     when 'wall_reply'
#       get_wall_post(attachment['wall_reply'], level)
#     when 'doc'
#       url = attachment['doc']['url'] 
#       title = attachment['doc']['title']

#       "#{prefix}Вложение (документ): #{title} (#{url})"
#     else
#       "#{prefix}Вложение (другое). FIXME: необработанный тип вложений!"
#     end
#   end.join("\n")

#   "#{result}\n"
# end

