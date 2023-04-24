require "sinatra"
require "metainspector"
require "json"

get "/" do
  "Nothing here!"
end

# Deprecated
get "/metadata" do
  url = params[:url]
  return halt 400, { error: "No URL provided" }.to_json if url.nil?

  url = "http://" + url if url[0..3] != "http"

  m = MetaInspector.new(url)
  properties = m.meta_tags["property"]

  {
    title: properties["og:title"],
    description: properties["og:description"],
    image: m.images.best,
    url: m.url,
    siteName: properties["og:site_name"],
    hostname: m.host
  }.to_json
rescue => e
  { error: "invalid url, #{e.message}" }.to_json
end

# All in one version
post "/metadata" do
  request_data = JSON.parse(request.body.read, symbolize_names: true)

  metadata_results = []

  request_data[:data].each do |url|
    url = "http://" + url if url[0..3] != "http"

    m = MetaInspector.new(url)
    properties = m.meta_tags["property"]

    metadata_results << {
      title: properties["og:title"],
      description: properties["og:description"],
      image: m.images.best,
      url: m.url,
      siteName: properties["og:site_name"],
      hostname: m.host
    }
  end

  { success: true, data: metadata_results }.to_json
rescue => e
  { error: "invalid url, #{e.message}" }.to_json
end
