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
