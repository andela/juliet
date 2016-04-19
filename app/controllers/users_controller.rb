class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
  end

  def create
    @user = User.first_or_create(user_params)
    # export_url = "https://www.linkedin.com/people/export-settings"
    # redirect_to export_url

    respond_to do |format|
      # format.html { redirect_to export_url }
      # format.json { head: no_content }
      format.js { flash[:notice] = "Identity Confirmed" }
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
