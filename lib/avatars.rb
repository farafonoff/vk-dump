# def get_avatar_txt(avatar)
#   url = get_best_photo_url(avatar)
#   likes_count = avatar['likes']['count']
#   reposts_count = avatar['reposts']['count']
#   comments_count = avatar['comments']['count']
#   text = avatar['text'].to_s
#   date = get_time_txt(avatar['date'])
#   id = avatar['id']

#   out = ''
#   out += "url: #{url}\n"
#   out += "date: #{date}\n"
#   out += "text: #{text}\n" unless text.empty?
#   out += "likes: #{likes_count}\n"

#   # if (likes_count > 0)
#   #   likes_user_ids = @vk.likes.getList(type: 'photo', item_id: id)['items']

#   #   out += "like user ids: #{likes_user_ids.join(", ")}\n"

#   #   sleep(@config['sleep_time'])
#   # end

#   out += "reposts: #{reposts_count}\n"
#   out += "comments: #{comments_count}\n"

#   # FIXME: комментарии должны получаться кусками за несколько запросов

#   # if (comments_count > 0)
#   #   comments_hashes = @vk.photos.getComments(photo_id: id)['items']
#   #   comments_txts = comments_hashes.map { |comment_hash| get_post_txt(comment_hash) }
#   #   comments_txt = comments_txts.join("\n")

#   #   out += text_indent(comments_txt)
#   # end

#   out
# end