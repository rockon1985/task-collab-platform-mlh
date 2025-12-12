#!/usr/bin/env ruby
# Test script to verify login functionality

require_relative 'config/environment'

email = 'demo@example.com'
password = 'Demo123!'

puts "="*60
puts "Testing Login Functionality"
puts "="*60

# Remove existing user if any
User.find_by(email: email)&.destroy
puts "\n1. Cleaned up existing user with email: #{email}"

# Create new user
user = User.create!(
  email: email,
  password: password,
  password_confirmation: password,
  first_name: 'Demo',
  last_name: 'User'
)
puts "2. Created user: #{user.email} (ID: #{user.id})"

# Test authentication
auth_result = AuthenticationService.authenticate(email, password)
if auth_result
  puts "3. ✓ Authentication successful: #{auth_result.full_name}"
else
  puts "3. ✗ Authentication FAILED"
  exit 1
end

# Test token generation
token = AuthenticationService.encode_token(user_id: user.id)
puts "4. ✓ Generated token: #{token[0..20]}..."

# Test token decoding
decoded = AuthenticationService.decode_token(token)
if decoded && decoded[:user_id] == user.id
  puts "5. ✓ Token decoded successfully: user_id=#{decoded[:user_id]}"
else
  puts "5. ✗ Token decode FAILED"
  exit 1
end

puts "\n" + "="*60
puts "SUCCESS! Use these credentials to login:"
puts "Email: #{email}"
puts "Password: #{password}"
puts "="*60
