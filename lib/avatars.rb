def get_avatars
  avatars = @vk.photos.get(album_id: AVATARS_ALBUM_ID, extended: 1)['items']

  avatars
end

def get_avatar_md(avatar)
  url = get_best_photo_url(avatar)
  likes_count = avatar['likes']['count']
  reposts_count = avatar['reposts']['count']
  comments_count = avatar['comments']['count']
  text = avatar['text'].to_s
  date = get_time_txt(avatar['date'])

  out = ''
  out += "\#\# #{date}\n\n"
  out += "_url:_ #{url}  \n"
  out += "_text:_ #{text}\n" unless text.empty?
  out += "_likes:_ #{likes_count}  \n"
  out += "_reposts:_ #{reposts_count}  \n"
  out += "_comments:_ #{comments_count}  \n"

  out
end
