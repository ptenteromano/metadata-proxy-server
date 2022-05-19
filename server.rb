require "sinatra"
require "metainspector"
require "json"

# https://x-team.com/blog/how-to-create-a-ruby-api-with-sinatra/

# We can do: namespace "/api/v1" do
# But that requires 'sinatra-contrib' gem.
before { content_type :json }

get "/" do
  { error: 'Nothing here!'}.to_json
end


get "/metadata" do
  url = params[:url]
  if url.nil?
    return halt 400, {error: "No URL provided"}.to_json
    # url = "https://dev.to/vetswhocode/vets-who-code-servicing-tech-opportunities-to-those-who-served-11lc"
  end

  url = "http://" + url if url[0..3] != "http"

  begin
    m = MetaInspector.new(url)
    {
      title: m.title,
      description: m.description,
      best_description: m.best_description,
      image: m.images.best,
      url: m.url,
      siteName: m.host,
      hostname: ""
    }.to_json
  rescue => e
    {
      error: "invalid url, #{e.message}"
    }.to_json
  end
end
