require 'httpclient'
require 'pry'

def get_final_url(uri)
  httpc = HTTPClient.new
  count = 0
  begin
    begin
      resp = httpc.get(uri)
      new_uri = resp.header['location'][0]
      break unless new_uri
      uri = new_uri
      puts uri
    end while (300..308).include?(resp.status)
  rescue
  end
  uri
end

# Pry.start(binding)



# def get_final_url(uri)
#   httpc = HTTPClient.new
#   count = 0
#   begin
#     begin
#       resp = httpc.get(uri)
#       uri = resp.header['location'][0]
#     end while (300..308).include? resp.status
#   rescue
#   end
#   uri
# end
# def get_final_url(uri)
#   httpc = HTTPClient.new
#   begin
#     resp = httpc.get(uri)
#     url = resp.header['location'][0]
#   end until (300..308).include? resp.status
#   url
# end

# x = 0
#
#   puts x += 1
  # puts index
  # begin
  #   final_dest = RedirectFollower.new(url).resolve.try(:response).try(:uri)
  # rescue OpenSSL::SSL::SSLError => e
  #   final_dest = url
  # end
