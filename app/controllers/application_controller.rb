class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_request
  before_action :set_current_attributes

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def authenticate_request
    token = extract_token_from_header
    @current_user = AuthenticationService.current_user_from_token(token)

    render_unauthorized unless @current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    header&.split(' ')&.last
  end

  def current_user
    @current_user
  end

  def set_current_attributes
    Current.user = current_user
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def forbidden(exception)
    render json: { error: exception.message }, status: :forbidden
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: {
      error: 'Validation failed',
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end
end
