class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, Rails.application.credentials.jwt_secret, "HS256")
  end

  def auth_header
    request.headers["Authorization"]
  end

  def decode_token
    if auth_header
      token = auth_header.split(" ")[1]
      begin
        JWT.decode(token, Rails.application.credentials.jwt_secret, true, algorithm: "HS256")
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decode_token
      user_id = decode_token[0]["user_id"]
      @current_user ||= User.find(user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: "Please log in" }, status: :unauthorized unless logged_in?
  end
end
