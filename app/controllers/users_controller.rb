class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
  end

  def create
    @user = User.first_or_create(user_params)
    session[:user_id] ||= @user.id
    respond_to do |format|
      format.js { flash[:notice] = "Identity Confirmed" }
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
