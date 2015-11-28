class PhotosController < ApplicationController

  def create
    params[:image].each do |image|
      Photo.new(image: image).save
    end
    redirect_to messages_path
  end
end
