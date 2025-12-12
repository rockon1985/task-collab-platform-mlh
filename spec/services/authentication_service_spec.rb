require 'rails_helper'

RSpec.describe AuthenticationService do
  describe '.encode_token' do
    it 'encodes a payload into a JWT token' do
      payload = { user_id: 1 }
      token = described_class.encode_token(payload)

      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3)
    end

    it 'includes expiration in the token' do
      payload = { user_id: 1 }
      token = described_class.encode_token(payload)
      decoded = JWT.decode(token, described_class::SECRET_KEY, true, algorithm: described_class::ALGORITHM)[0]

      expect(decoded['exp']).to be_present
    end
  end

  describe '.decode_token' do
    it 'decodes a valid token' do
      payload = { user_id: 1 }
      token = described_class.encode_token(payload)
      decoded = described_class.decode_token(token)

      expect(decoded['user_id']).to eq(1)
    end

    it 'returns nil for invalid token' do
      expect(described_class.decode_token('invalid_token')).to be_nil
    end

    it 'returns nil for expired token' do
      payload = { user_id: 1, exp: 1.hour.ago.to_i }
      expired_token = JWT.encode(payload, described_class::SECRET_KEY, described_class::ALGORITHM)

      expect(described_class.decode_token(expired_token)).to be_nil
    end
  end

  describe '.authenticate' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'Password123!') }

    it 'returns user for valid credentials' do
      result = described_class.authenticate('test@example.com', 'Password123!')
      expect(result).to eq(user)
    end

    it 'updates last_login_at on successful authentication' do
      expect {
        described_class.authenticate('test@example.com', 'Password123!')
      }.to change { user.reload.last_login_at }.from(nil)
    end

    it 'returns nil for invalid password' do
      result = described_class.authenticate('test@example.com', 'wrong_password')
      expect(result).to be_nil
    end

    it 'returns nil for non-existent email' do
      result = described_class.authenticate('nonexistent@example.com', 'Password123!')
      expect(result).to be_nil
    end
  end

  describe '.current_user_from_token' do
    let!(:user) { create(:user) }

    it 'returns user for valid token' do
      token = described_class.encode_token(user_id: user.id)
      result = described_class.current_user_from_token(token)

      expect(result).to eq(user)
    end

    it 'returns nil for invalid token' do
      result = described_class.current_user_from_token('invalid_token')
      expect(result).to be_nil
    end

    it 'returns nil for nil token' do
      result = described_class.current_user_from_token(nil)
      expect(result).to be_nil
    end
  end
end
