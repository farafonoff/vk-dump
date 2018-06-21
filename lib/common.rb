def get_token(url)
  url.scan(/access_token=([^&]+)/).first.first
end

def get_id_from_filename(str)
  str.scan(/[0-9]+/).first.to_i
end

def text_indent(text)
  prefix = @config['prefix_string']
  text.each_line.map { |line| prefix + line }.join
end

def get_best_photo_url(photos)
  resolution_strings = photos.keys.find_all do |str|
    str.include? 'photo_'
  end

  resolutions = resolution_strings.map do |str|
    str.scan(/photo_([0-9]+)/).first.first.to_i
  end

  photo_url = photos["photo_#{resolutions.max}"]

  "#{photo_url}"
end

def get_time_txt(time)
  res = Time.at(time).strftime(@config['time_format'])

  res
end