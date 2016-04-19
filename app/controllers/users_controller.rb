class UsersController < ApplicationController
  def index
  end

  def new
  end

  def show
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to page_path('thankyou')
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :attachment)
    end

end
