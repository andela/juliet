class UsersController < ApplicationController
  def index
  end

  def new
  end

  def show

  end

  def create
    Tokenizer.refresh_token
    session[:token] = env["omniauth.auth"]["credentials"]["token"]
    redirect_to user_path(id: 1)
  end


  private


end
