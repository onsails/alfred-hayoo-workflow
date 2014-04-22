require 'net/http'
require 'json'

def item_xml(options = {})
  <<-ITEM
  <item arg="#{options[:arg]}" uid="#{options[:uid]}">
    <title>#{options[:title]}</title>
    <subtitle>#{options[:subtitle]}</subtitle>
    <icon>#{options[:path]}</icon>
  </item>
  ITEM
end

def query q
  uri = URI.parse(URI.encode("http://holumbus.fh-wedel.de/hayoo/hayoo.json?query=#{q}"))

  JSON.parse(Net::HTTP.get(uri))
end

scope = ARGV[0]
response = query ARGV[1]

if scope == 'package'
  items = response['packages'].map do |result|
    item_xml({ :arg => "https://hackage.haskell.org/package/" + result['name'], :title => result['name'],
               :uid => result['name'] })
  end.join
elsif scope == 'function'
  items = response['functions'].map do |result|
    title = result['name'] + " :: " + result['signature']

    description = result['description'].gsub(/<[^>]*>/ui,'')

    subtitule = '(' + result['module'] + ') ' + description

    item_xml({ :arg => result['uri'], :title => title,
               :subtitle => subtitule,
               :uid => result['uri'] })
  end.join
end

output = "<?xml version='1.0'?>\n<items>\n#{items}</items>"

puts output
