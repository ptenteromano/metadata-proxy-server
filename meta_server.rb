require "sinatra"
require "metainspector"
require "json"

get "/" do
  "Nothing here!"
end

# All in one version
post "/metadata" do
  request_data = JSON.parse(request.body.read, symbolize_names: true)

  { success: true, data: collect_metadata(request_data[:data]) }.to_json
rescue => e
  { error: "invalid url, #{e.message}" }.to_json
end

# Read through all urls and collect metadata
def collect_metadata(data)
  data.map do |url|
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
    }
  end
end
