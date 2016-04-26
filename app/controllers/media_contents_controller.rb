class MediaContentsController < ApplicationController
  before_action :is_verified?

  def create
    @contact_file = attachment.original_filename
    @file_ext = @contact_file.split(".").last.downcase
    path = Rails.root.join("public", "uploads", filename)
    if valid_ext?(@file_ext)
      @media = current_user.medias.new(file_name: filename)
      begin
        save_file(@media, path)
      rescue
        response_json("error", "An error occurred. Please, try again.")
      end
    else
      response_json("error", "Invalid file type. Upload your LinkedIn .csv or .vcf file")
    end
  end

private
  def media_params
    params.permit(:file)
  end

  def attachment
    media_params[:file]
  end

  def temp_save(path)
    File.open(path, 'wb') do |file|
      file.write(attachment.read)
    end
  end

  def filename
    @contact_file.split(".")[0..-2].join.gsub(/\s/,"") + "_" + current_user.email + "." + @file_ext
  end

  def valid_ext?(file_ext)
    allowed_types.include? file_ext
  end

  def allowed_types
   %w(csv vcf)
  end

  def save_file(media, path)
    if media.save!
      temp_save(path)
      SaveToDrive.perform_async(path, filename)
      respond_to do |format|
        format.json { render json: media }
      end
    end
  end

  def response_json(key, val)
    respond_to do |format|
      format.json { render json: { key => val } }
    end
  end

end
