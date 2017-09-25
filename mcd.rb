require 'slop'
require 'json'

def load_urls
  file = File.open 'urls.json', 'rb'
  file.read.to_json
end

def write_urls(urls)
  file = File.open 'urls.json', 'w'
  puts urls
  file.write urls
end

def main
  opts = Slop.parse do |o|
    o.string '-a', '--add', 'add a new url'
    o.string '-s', '--start', 'start the app'
  end

  urls = load_urls

  if opts.add?
    url = opts[:add]
    urls[:data] << { url: url }
    write_urls(urls)
  end
end

main if $PROGRAM_NAME == __FILE__
