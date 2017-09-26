require 'slop'
require 'json'
require 'net/http'
require 'uri'
require 'date'

def load_data
  file = File.open 'data.json', 'rb'
  JSON.parse file.read
end

def write_data(data)
  file = File.open 'data.json', 'w'
  file.write data.to_json
end

def send_get(url)
  Net::HTTP.get URI url
end

def main
  opts = Slop.parse do |o|
    o.string '-a', '--add', 'add a new episode'
  end

  data = load_data

  if opts.add?
    url = format 'http://api.tvmaze.com/singlesearch/shows?q=%s', opts[:add]
    resp = JSON.parse send_get url
    episode_url = resp['_links']['nextepisode']['href']
    episode = JSON.parse send_get episode_url
    release_date = episode['airdate']
    data.push(name: opts[:add], url: url, release_date: release_date)
    write_data data
  else
    data.each_with_index do |entry, i|
      if Date.today >= Date.parse(entry['release_date'], '%Y-%m-%d')
        puts "#{entry['name']} released!"
        resp = JSON.parse send_get entry['url']
        episode_url = resp['_links']['nextepisode']['href']
        episode = JSON.parse send_get episode_url
        release_date = episode['airdate']
        data[i]['release_date'] = release_date
        write_data data
      end
    end
  end
end

main if $PROGRAM_NAME == __FILE__
