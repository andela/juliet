class ApplicationController < ActionController::Base
  protect_from_forgery #with: :exception

  def current_user
    User.find_by_id(session[:user_id])
  end

  def is_verified?
    unless current_user
      flash[:error] = "You must confirm your identity first."
      redirect_to root_url
    end
  end
end
