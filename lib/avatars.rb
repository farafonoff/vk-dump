def get_avatars
  params = { album_id: AVATARS_ALBUM_ID, extended: 1, count: @config['avatars_count'] }
  avatars = @vk.photos.get(params)['items']

  avatars
end

def get_avatar_likes(avatars)
  likes_hash = {}
  profile_ids_raw = []

  avatars.each do |avatar|
    target_id = avatar['id'].to_i
    like_ids = @vk.likes.getList(type: 'photo', item_id: target_id)[:items]

    likes_hash[target_id] = like_ids
    profile_ids_raw.push *like_ids

    sleep @config['sleep_time']
  end

  profile_ids = (profile_ids_raw || []).uniq
  profiles = get_user_profiles(profile_ids)

  { likes_hash: likes_hash, profiles: profiles }
end

def get_avatar_comments(avatars)
  comments_hash = {}

  avatars.each do |avatar|
    target_id = avatar['id'].to_i
    comments_count = @vk.photos.getComments(photo_id: target_id)['count']

    if comments_count > 0
      comments = @vk.photos.getComments(photo_id: target_id, count: @config['avatar_comments_count'])
      comments_hash[target_id] = comments
    end

    sleep @config['sleep_time'] 
  end

  comments_hash.extend Hashie::Extensions::DeepFind
  user_ids = [ comments_hash.deep_find_all('from_id'), comments_hash.deep_find_all('user_id') ].flatten.uniq
  profiles = get_user_profiles(user_ids)
  
  { comments: comments_hash, profiles: profiles }
end

def get_avatar_md(avatar, avatar_likes, avatar_comments)
  url = get_best_photo_url(avatar)

  id = avatar['id']
  likes_count = avatar['likes']['count']
  reposts_count = avatar['reposts']['count']
  comments_count = avatar['comments']['count']
  text = avatar['text'].to_s
  date = get_time_txt(avatar['date'])

  out = ''
  out += "\#\# #{date}\n\n"
  out += "_id:_ #{id}  \n"
  out += "_url:_ #{url}  \n"
  out += "_text:_ #{text}\n" unless text.empty?
  out += "_reposts:_ #{reposts_count}  \n"
  out += "_comments:_ #{comments_count}  \n"

  liked_profiles = avatar_likes[:profiles]

  if likes_count > 0
    liked_ids = avatar_likes[:likes_hash][id]
    liked_names = liked_ids.map { |profile_id| liked_profiles[profile_id] }

    out += "_liked by (#{likes_count}):_ #{liked_names.join(', ')}  \n"
  end

  if comments_count > 0
    comments = avatar_comments[:comments][id]['items']
    comment_profiles = avatar_comments[:profiles]
    comments_md = comments.map { |comment| get_post_md(comment, comment_profiles) }.join("\n")

    out += "_Comments (#{comments_count}):  \n"
    out += text_indent(comments_md)
  end

  out
end
