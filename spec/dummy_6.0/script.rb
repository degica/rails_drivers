include Rack::Test::Methods
def app; Rails.application; end

get '/'
puts last_response.body
