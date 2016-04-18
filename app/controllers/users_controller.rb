class UsersController < ApplicationController
  def index
  end

  def new
  end

  def show

  end

  def create
    token_expiry = Time.at(env["omniauth.auth"]["credentials"]["token"]["expires"])
    Tokenizer.refresh_token if token_expiry < 1.day.from_now
    session[:token] = env["omniauth.auth"]["credentials"]["token"]
    redirect_to user_path(id: 1)
  end


  private


end
