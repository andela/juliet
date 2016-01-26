require 'httpclient'
require 'uri'
require 'typhoeus'

module URLable
  # def get_final_url(uri)
  #   httpc = HTTPClient.new
  #   begin
  #     t = Thread.new do
  #       puts "New thread started"
  #       begin
  #         resp = httpc.get(uri)
  #         new_uri = resp.header['location'][0]
  #         break unless new_uri && new_uri =~ URI::regexp
  #         # puts new_uri
  #         uri = new_uri
  #       end while (300..308).include?(resp.status)
  #     end
  #     t.join
  #   rescue
  #   end
  #   uri
  # end

  def get_final_url(uri)
    # Thread.new{
      new_url = Typhoeus.get(uri, followlocation: true).effective_url
    # }.join
  end
end
