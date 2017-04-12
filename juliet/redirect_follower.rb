require 'logger'
require 'net/https'

class RedirectFollower
  class TooManyRedirects < StandardError; end

  attr_accessor :url, :redirect_limit, :response

  def initialize(url, limit=5)
    @url, @redirect_limit = url, limit
    # logger.level = Logger::INFO
  end

  # def logger
  #   @logger ||= Logger.new(STDOUT)
  # end

  def resolve
    raise TooManyRedirects if redirect_limit < 0

    begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)

      self.response = http.request(request)
      # response.body
      # self.response = Net::HTTP.get_response(uri) do |http|
      #   http.use_ssl = true
      #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      # end
    rescue StandardError => e
      puts url
      puts e.message
    end


    if response.kind_of?(Net::HTTPRedirection)
      self.url = redirect_url
      self.redirect_limit -= 1
      resolve
    end

    # self.body = response.body
    self
  end

  def redirect_url
    if response['location'].nil?
      response.body.match(/<a href=\"([^>]+)\">/i)[1]
    else
      response['location']
    end
  end
end



# require 'faraday'
# require 'faraday_middleware'


# $faraday = Faraday.new(ssl: {verify: false}) do |f|
#   f.use FaradayMiddleware::FollowRedirects
#   f.adapter :net_http
# end


  # begin
    # self.response = $faraday.get(URI.parse(url))
  # rescue
  #
  # end

  # logger.info "redirect limit: #{redirect_limit}"
  # logger.info "response code: #{response.code}"
  # logger.debug "response body: #{response.body}"
# unless url == response.to_hash[:url].to_s
# logger.info "redirect found, headed to #{url}"


# http://www.railstips.org/blog/archives/2009/03/04/following-redirects-with-nethttp/
