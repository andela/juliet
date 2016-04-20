class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    session.clear
  end

  def create
    @user = User.where(user_params).first_or_create
    session[:user_id] ||= @user.id
    respond_to do |format|
      format.js { flash[:notice] = "Identity Confirmed" } if current_user
      format.js { flash[:error] = "Invalid Details" } unless current_user
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
