def get_avatars
  avatars = @vk.photos.get(album_id: AVATARS_ALBUM_ID, extended: 1)['items']

  avatars
end

def get_avatar_raw(target_id, avatars)
  avatar = avatars.find{|elt| elt[:id] == target_id }
  like_ids = @vk.likes.getList(type: 'photo', item_id: target_id)[:items]
  like_profiles = get_user_profiles(like_ids)
  
  comments_count = avatar['comments']['count']
  comments = []

  # FIXME: обработка вложений
  
  if comments_count > 0
    comments = @vk.photos.getComments(photo_id: target_id)
  end

  { avatar: avatar, like_profiles: like_profiles, comments: comments }
end

def get_avatar_md(avatar_hash)
  avatar = avatar_hash[:avatar]

  url = get_best_photo_url(avatar)

  id = avatar['id']
  likes_count = avatar['likes']['count']
  reposts_count = avatar['reposts']['count']
  comments_count = avatar['comments']['count']
  text = avatar['text'].to_s
  date = get_time_txt(avatar['date'])
  comments = avatar_hash[:comments]

  out = ''
  out += "\#\# #{date}\n\n"
  out += "_id:_ #{id}  \n"
  out += "_url:_ #{url}  \n"
  out += "_text:_ #{text}\n" unless text.empty?
  out += "_likes:_ #{likes_count}  \n"
  out += "_liked by:_ #{avatar_hash[:like_profiles].values.join(', ')}  \n" if likes_count > 0
  out += "_reposts:_ #{reposts_count}  \n"
  out += "_comments:_ #{comments_count}  \n"
  out += "#{comments.inspect}  \n" if comments_count > 0
  out
end
