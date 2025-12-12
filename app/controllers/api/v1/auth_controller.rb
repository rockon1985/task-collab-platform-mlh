class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register]

  # POST /api/v1/auth/register
  def register
    user = User.new(user_params)

    if user.save
      token = AuthenticationService.encode_token(user_id: user.id)
      render json: {
        user: UserSerializer.new(user).as_json,
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/auth/login
  def login
    user = AuthenticationService.authenticate(login_params[:email], login_params[:password])

    if user
      token = AuthenticationService.encode_token(user_id: user.id)
      render json: {
        user: UserSerializer.new(user).as_json,
        token: token
      }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  # GET /api/v1/auth/me
  def me
    render json: UserSerializer.new(current_user).as_json
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end
