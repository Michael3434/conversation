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

    # Shortcut for this: @images_names = current_user.photos.map(&:image_file_name)
    @images_names = []
    current_user.photos.each do |photo|
      @images_names << photo.image_file_name
    end

    # What is @a? => hard to understand
    # Another to do this is by defining the method that gets the list of all messages between User A and User B in the User model:
    #
    # receiver = User.where(email: params[:email_to]).first
    # if receiver
    #   @conversation = current_user.messages_with(receiver)
    # end
    #
    # See User.rb for the implementation of messages_with
    # Now you can reuse this method everytime you need to fetch the conversation between to users
    @a = @messages.group_by do |rec|
      [rec.sent_messageable_id , rec.received_messageable_id].sort
    end
    user_id = User.where(email: params[:email_to]).first.id
    @a.keys.each_with_index do |key, index|
      if key.include? user_id
        @conversation = @a.values[index] # Or @a[key]
      end
    end
    if !@conversation.nil?
      if current_user.id == @conversation.first.sent_messageable_id
      else
        # Indent your code so it's more readable
      mark_as_read(@conversation)
      end
    end
    @message = Message.new
    @user = current_user
  end

  def create
    @photo = Photo.new
    if !current_user.photos.nil?
      p current_user.photos
      p params[:message][:topic]
      p "LOOOOOOOOOL"
      p @image

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

  # It's really hard to understand what you want to do in this method, try to put comment
  # so it's easier to read for someone else.
  # To improve readability, try to follow some rule when naming variables :
  # If it's an array with more than one element, use plural : @bodies

  # Also it seems you try to fetch the last message sent in each conversation to display it in the view.
  # This is a method that would go well in a custom class (https://github.com/LTe/acts-as-messageable#custom-class)
  # So you could define :
  #     def last_message
  #       .. your code that returns the last message
  #     end
  #
  #
  # Then in your views you would do :
  #   <% @conversations.each do |conversation| %>
  #     <div><%= conversation.last_message.email %></div>
  #     <div><%= conversation.last_message.body %></div>
  #   <% end %>
  def get_conversation
   @messages = current_user.messages.order("created_at ASC") if !current_user.messages.nil?
   # Name your variables with something readalbe, It's not easy to understand what @a is ?
   # Ex: @conversations (since your grouping by sender and receiver, each group is actually a conversation)
    @a = @messages.group_by do |rec| # better: group_by do |message| => more readable
      [rec.sent_messageable_id , rec.received_messageable_id].sort
    end
    times = @a.keys.length
    x = 0
    @body = []
    @email = []
    # Instead of doing @a.length.times do... you can do directly : @a.each do |key, value| ... end
    # This is much easier to understand :).
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

  def mark_as_read(message) # better to use `messages` because it holds many messages
    # Then you can do messages.each do |message|
    # Also a shortcut: messages.update_all(opened: true)
    message.each do |mess|
      mess.update(opened: true)
    end
  end

end
