def get_avatar_txt(avatar)
  url = get_best_photo_url(avatar)
  likes_count = avatar['likes']['count']
  reposts_count = avatar['reposts']['count']
  comments_count = avatar['comments']['count']
  text = avatar['text'].to_s
  date = get_time_txt(avatar['date'])
  id = avatar['id']

  out = ''
  out += "url: #{url}\n"
  out += "date: #{date}\n"
  out += "text: #{text}\n" unless text.empty?
  out += "likes: #{likes_count}\n"

  if (likes_count > 0)
    likes_user_ids = @vk.likes.getList(type: 'photo', item_id: id)['items']

    out += "like user ids: #{likes_user_ids.join(", ")}\n"

    sleep(@config['sleep_time'])
  end

  out += "reposts: #{reposts_count}\n"
  out += "comments: #{comments_count}\n"

  out
end