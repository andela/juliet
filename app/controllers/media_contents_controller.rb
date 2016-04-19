class MediaContentsController < ApplicationController

  def create
    @contact_file = media_params[:attachment].original_filename
    @file_ext = @contact_file.split(".").last.downcase
    if valid_ext?(@file_ext)
      path = Rails.root.join("public", "uploads", @contact_file)
      temp_save(path)
      @session = GoogleDrive.saved_session("config.json")
      save_to_drive(path)
    else
      flash[:error] = "Invalid file type. Upload your LinkedIn .csv or .vcf file"
      redirect_to root_url
    end
  end


private
  def media_params
    params.permit(:attachment)
  end

  def temp_save(path)
    File.open(path, 'wb') do |file|
      file.write(media_params[:attachment].read)
    end
  end

  def filename
    @contact_file.split(".")[0..-2].join + Time.now.to_i.to_s + "." + @file_ext
  end

  def valid_ext?(file_ext)
    allowed_types.include? file_ext
  end

  def allowed_types
    %w(csv vcf)
  end

  def save_to_drive(path)
    if @session.upload_from_file("#{path}", "#{filename}", convert: false)
      File.delete(path)
      redirect_to user_path(session[:user_id]) if current_user.medias.create!(file_name: filename)
    else
      flash[:error] = "An error occurred. Please, try again."
      redirect_to root_url
    end
  end
end
