class PhotosController < ApplicationController

  def create
    current_user.id
    params[:image].each do |image|
      Photo.new(image: image, user_id: current_user.id).save
    end
    redirect_to messages_path
  end
end
