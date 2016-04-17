require "rest-client"
class Tokenizer
  class << self
    def refresh_token
      url = "https://www.linkedin.com/uas/oauth2/authorization"
      callback = "http://localhost:3000/auth/linkedin/callback"
      data = "application/x-www-form-urlencoded"
      RestClient.post url, { response_type: "code", client_id: ENV["LINKEDIN_CLIENT_ID"],
                             redirect_uri: callback, state: ENV["LINKEDIN_STATE"]}, {content_type: data}
    end
  end
end