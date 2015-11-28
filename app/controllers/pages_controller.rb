class PagesController < ApplicationController
  def home
    @photo = Photo.new
    @users = User.all
    @messages = Message.all
  end

  def create
    raise
  end

end
