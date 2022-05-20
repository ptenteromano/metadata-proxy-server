require "sinatra"
require "metainspector"
require "json"

# https://x-team.com/blog/how-to-create-a-ruby-api-with-sinatra/

# We can do: namespace "/api/v1" do
# But that requires 'sinatra-contrib' gem.
configure do
  enable :cross_origin
end

before do
  content_type :json
  response.headers['Access-Control-Allow-Origin'] = '*'
end

get "/" do
  { error: 'Nothing here!'}.to_json
end

get "/metadata" do
  url = params[:url]
  if url.nil?
    return halt 400, {error: "No URL provided"}.to_json
  end

  url = "http://" + url if url[0..3] != "http"

  begin
    m = MetaInspector.new(url)
    properties = m.meta_tags['property']

    {
      title: properties['og:title'],
      description: properties['og:description'],
      image: m.images.best,
      url: m.url,
      siteName: properties['og:site_name'],
      hostname: m.host
    }.to_json
  rescue => e
    {
      error: "invalid url, #{e.message}"
    }.to_json
  end
end
