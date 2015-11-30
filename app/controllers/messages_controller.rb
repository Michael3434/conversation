    require 'open-uri'
class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @photo = Photo.new
    @users = User.all
    get_conversation
  end

  def outbox
    @messages = current_user.sent_messages
  end

  def download_image

    byebug
    send_file( "http://<localhost:3000 id="">params[:file]</localhost:3000>", type: 'image/jpeg', disposition: 'attachment')
  end

  def show
  end

  def download_message_picture
    @message = Message.find(params[:message])
    image_name = @message.photo.image_file_name
    open('logo_faccebook.jpg', 'wb') do |file|
    file << open("http://localhost:3000/system/photos/images/000/000/001/medium/logo_faccebook.jpg?1448572538").read
    end


    # send_file "http://localhost:3000#{@message.photo.image.url()}", :type=>"image/jpg", :x_sendfile=>true
    # @image_name = @message.photo.image_file_name
    # @image_url = @message.photo.image.url()

    # data = open("http://localhost:3000/system/photos/images/000/000/001/medium/logo_faccebook.jpg?1448572538", 'rb').read

    # send_data data, :disposition => 'attachment', :filename=> "#{@image_name}", type: @message.photo.image_content_type
    # raise
    # @message = Message.find(params[:message])
    # @message.photo.image = URI::parse("http://localhost:3000#{@message.photo.image.url()}").to_s
  end

  def destroy
    @message = current_user.messages.find(params[:id])
    if @message.destroy
      flash[:notice] = "All ok"
    else
      flash[:error] = "Fail"
    end
  end

  def new
    @photo = Photo.new
    @users = User.all

    get_conversation

    @images_names = []
    current_user.photos.each do |photo|
      @images_names << photo.image_file_name
    end

    get_conversation1

    if !@conversation.nil?
      if current_user.id == @conversation.first.sent_messageable_id
      else
      mark_as_read(@conversation)
      end
    end
    @message = Message.new

    @user = current_user

    ###### Get time ######
    if current_user.manager == true
      @conversation.reverse.each do |mess|
        if mess.received_messageable_id == current_user.id
          @time_last_message_received = mess.created_at
        end
      end
      @conversation.reverse.each do |mess|
        if mess.sent_messageable_id == current_user.id
          @time_last_message_sent = mess.created_at
        end
      end
    end
    @time_to_answer = @time_last_message_received - @time_last_message_sent
    if @time_to_answer.to_s.include? "-"
      # current_user.average_time_answer
    else
    end
    ##########################

  end

  def create
    @photo = Photo.new
    if !current_user.photos.nil?

    end
      @email = params[:message][:sent_messageable_id]
      @to = User.where(email: @email).first
      @message = current_user.send_message(@to, { body: params[:message][:body], topic: params[:message][:topic] })

      @image = current_user.photos.where(image_file_name: params[:message][:topic]).first
      @message.photo_id = @image.id if !@image.nil?
      @message.save
      respond_to do |format|
        format.html { redirect_to new_message_path(email_to: @email) }
        format.js  # <-- will render `app/views/reviews/create.js.erb`
      end
  end

  def get_conversation1
    @other_user_id = User.where(email: params[:email_to]).first.id
    @conversation = []
    current_user.messages.each do |mess|
      if mess.received_messageable_id == current_user.id && mess.sent_messageable_id == @other_user_id
        @conversation << mess
      elsif mess.sent_messageable_id == current_user.id && mess.received_messageable_id == @other_user_id
        @conversation << mess
      end
    end
    @conversation
  end

  def get_conversation
   @messages = current_user.messages.order("created_at ASC") if !current_user.messages.nil?
    @a = @messages.group_by do |rec|
      [rec.sent_messageable_id , rec.received_messageable_id].sort
    end
    times = @a.keys.length
    x = 0
    @body = []
    @email = []
    times.times do
      if @a.values[x].first.body.include? "Image_inside"
        value = @a.values[x].first.body + x.to_s
        @body << value
      else
        @body << @a.values[x].first.body
      end
      if @a.values[x].first.sent_messageable_id == current_user.id
        @email << @users.find(@a.values[x].first.received_messageable_id).email

      else
        @email << @users.find(@a.values[x].first.sent_messageable_id).email
      end
    x += 1
    end
    @body.reverse
    @email.reverse
    @all_conversations = Hash[@body.zip @email]
  end

  def mark_as_read(message)
    message.each do |mess|
      mess.update(opened: true)
    end
  end

end
