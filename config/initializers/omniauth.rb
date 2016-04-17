Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, ENV["LINKEDIN_CLIENT_ID"], ENV["LINKEDIN_SECRET"],
  scope: 'r_basicprofile r_emailaddress',
  fields: ['id', 'picture-url', 'email-address', 'first-name', 'last-name', 'location',
           'industry', 'public-profile-url'],
  secure_image_url: true
end