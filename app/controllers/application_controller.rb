class ApplicationController < ActionController::Base
  protect_from_forgery
  # before_action :reset_current_user_session

  def current_user
    User.find_by_id(session[:current_user_id])
  end

  # def reset_current_user_session
  #   session[:current_user_id] = nil
  # end

  # def is_verified?
  #   unless current_user
  #     flash[:error] = "You must confirm your identity first."
  #     redirect_to root_url
  #   end
  # end
end
