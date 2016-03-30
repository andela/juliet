message = { status: 200 }

post "/" do
  cross_origin
  query = params["company"]
  url = Searcher.new(query)
  message[:url] = url.look_up_coy_url
  message.to_json
end
