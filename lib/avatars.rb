def get_avatar_txt(avatar)
  url = get_best_photo_url(avatar)
  likes_count = avatar['likes']['count']
  reposts_count = avatar['reposts']['count']
  comments_count = avatar['comments']['count']
  text = avatar['text'].to_s
  date = get_time_txt(avatar['date'])

  out = ''
  out += "url: #{url}\n"
  out += "date: #{date}\n"
  out += "text: #{text}\n" unless text.empty?
  out += "likes: #{likes_count}\n"
  out += "reposts: #{reposts_count}\n"
  out += "comments: #{comments_count}\n"

  out
end