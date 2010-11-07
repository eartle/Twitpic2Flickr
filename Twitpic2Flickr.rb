
require 'rubygems'
require 'flickr'
require 'net/http'
require 'uri'
require 'rexml/document'
require 'cgi'

# Constants
twipicKey = '809c5e5aee69981a2e959e4c0b602f6c'
flickrKey = '2203485b84d129df9f81b4516b9f67d3'
flickrSecret = '0d0bccbc8ff627cc'

# A fetcher that can handle redirecting
def fetch(uri_str, limit = 10)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  response = Net::HTTP.get_response(URI.parse(uri_str))
  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  else
    response.error!
  end
end

# Create flickr session and authenticate if needed
flickr = Flickr.new('MY_TOKEN', flickrKey, flickrSecret)
unless flickr.auth.token
  flickr.auth.getFrob
  url = flickr.auth.login_link
  puts "You must visit #{url} to authorize this application.  Press enter when you have done so. This is the only time you will have to do this."
  gets
  flickr.auth.getToken
  flickr.auth.cache_token
end

username = ARGV[0]

# Get the photo info from Twitpic
xml_data = Net::HTTP.get_response(URI.parse("http://api.twitpic.com/2/users/show.xml?username=#{username}")).body
doc = REXML::Document.new(xml_data)

# Find the last page of Twitpic images
photo_count = doc.elements['user/photo_count'].text
perPage = 20
lastPage = (Integer(photo_count) / 20).ceil

lastPage.times do |index|
  # loop backwards through the Twipic pages (so we upload in chronological order)
  xml_data = Net::HTTP.get_response(URI.parse("http://api.twitpic.com/2/users/show.xml?username=#{username}&page=#{lastPage - index}")).body
  doc = REXML::Document.new(xml_data)

  doc.elements.reverse_each('user/images/image') do |image|
    # loop backwards though the images in a page (so we upload in chronological order)
    short_id = image.elements['short_id'].text
    message = image.elements['message'].text
    if message
      message = CGI.unescapeHTML(message)
    end
    type = image.elements['type'].text
  
    print "#{short_id} #{message}\n";
  
    # Get the full size imge from Twitpic
    image_data = fetch("http://twitpic.com/show/full/#{short_id}").body
  
    # upload the image to Flickr
    flickr.photos.upload.upload_image(image_data, "image/#{type}", short_id, message, nil, ['Twitpic', 'Twitpic2Flickr', short_id])
  end
end
