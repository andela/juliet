class MediaContentsController < ApplicationController
  #skip_before_filter :login_required, only: [:new, :create]
  # before_action :is_verified?, :attachment_present?
  # before_action :is_verified?

  def create
    @user = User.find_by_id(session[:current_user_id])
    @media = Media.new(file_name: params[:file], user_id: @user.id)

    @file_path = Rails.root.join("public", "uploads", params[:file].original_filename)
    @gdrive_session = GoogleDrive.saved_session("config.json")

    if @media.save!
      temp_save(@file_path)
      @gdrive_session.upload_from_file("#{@file_path}", "#{params[:file].original_filename}", convert: false)
      File.delete(@file_path)
      redirect_to user_path(@user)
    end
  end

  # def create
  #   @contact_file = attachment.original_filename
  #   @file_ext = @contact_file.split(".").last.downcase
  #
  #   if valid_ext?(@file_ext)
  #     path = Rails.root.join("public", "uploads", @contact_file)
  #     temp_save(path)
  #     @session = GoogleDrive.saved_session("config.json")
  #     save_to_drive(path)
  #   else
  #     flash[:error] = "Invalid file type. Upload your LinkedIn .csv or .vcf file"
  #     redirect_to root_url
  #   end
  # end

private
  # def media_params
  #   params.permit(:attachment)
  # end

  # def attachment
  #   media_params[:attachment]
  # end
  #
  # def attachment_present?
  #   unless attachment && attachment != ""
  #     flash[:error] = "You must attach a file."
  #     redirect_to root_url
  #   end
  # end
  #
  # def temp_save(path)
  #   File.open(path, 'wb') do |file|
  #     file.write(attachment.read)
  #   end
  # end

  def temp_save(path)
    File.open(path, 'wb') do |file|
      file.write(params[:file].read)
    end
  end
  #
  # def filename
  #   @contact_file.split(".")[0..-2].join + "_" + Time.now.to_i.to_s + "." + @file_ext
  # end

  #def valid_ext?(file_ext)
    #allowed_types.include? file_ext
  #end

  #def allowed_types
  #  %w(csv vcf)
  #end
  #
  # def save_to_drive(path)
  #   if @session.upload_from_file("#{path}", "#{filename}", convert: false)
  #     File.delete(path)
  #     redirect_to user_path(current_user.id) if current_user.medias.create(file_name: filename)
  #   else
  #     flash[:error] = "An error occurred. Please, try again."
  #     redirect_to root_url
  #   end
  # end
end
