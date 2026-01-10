class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_user_id

  private

  def redis
    RedisClient.connection
  end

  def set_user_id
    @user_id = request.headers["X-USER-ID"] || session[:user_id] ||= SecureRandom.uuid
  end
end
