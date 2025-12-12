module RequestHelpers
  def auth_headers(user)
    token = AuthenticationService.encode_token(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
