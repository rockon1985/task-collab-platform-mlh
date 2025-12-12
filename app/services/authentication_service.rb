# Authentication service to handle JWT token operations
class AuthenticationService
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE']
  ALGORITHM = 'HS256'.freeze
  TOKEN_EXPIRATION = 24.hours

  class << self
    def encode_token(payload)
      payload[:exp] = TOKEN_EXPIRATION.from_now.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def decode_token(token)
      JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)[0]
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.error("JWT Decode Error: #{e.message}")
      nil
    end

    def authenticate(email, password)
      user = User.find_by(email: email.downcase.strip)
      return nil unless user&.authenticate(password)

      user.update_last_login!
      user
    end

    def current_user_from_token(token)
      return nil unless token

      decoded = decode_token(token)
      return nil unless decoded

      User.find_by(id: decoded['user_id'])
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
