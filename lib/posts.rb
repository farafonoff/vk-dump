# def get_wall_post(post, level)
#   # TODO: сделать обработку вложений у постов

#   #binding.pry

#   prefix = get_prefix(level)
#   next_prefix = get_prefix(level + 1)

#   text = prefix_multiline(post['text'], next_prefix)
#   date = Time.at(post['date'])
#   author = post['from_id']

#   if (post['post_type'] == 'post')
#     pre_header = "#{prefix}Вложение (пост):\n"
#   else
#     pre_header = "#{prefix}Вложение (ответ на пост):\n"
#   end

#   header = "#{next_prefix}[#{date} #{author}]:\n"
  
#   pre_header + header + text
# end

# def make_header(post)
#   time = Time.at(post['date']).strftime(@config['time_format'])

#   "[#{time} #{post['from_id']}]:"
# end

# def make_footer(post)
#   likes_count = post['likes']['count']
#   reposts_count = post['reposts']['count']

#   "-- Likes: #{likes_count}, Reposts: #{reposts_count} --"
# end