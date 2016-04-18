class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # helper_method :headie

  # def headie
  #   request.headers["leo_auth_token"] = session[:token] if session[:token]
  # end
end
