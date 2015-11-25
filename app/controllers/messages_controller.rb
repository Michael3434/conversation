class MessagesController < ApplicationController
  def index
    @current_user = current_user
    @users = User.all
    @messages = current_user.messages.order("created_at ASC")
    @a = @messages.group_by do |rec|
      [rec.sent_messageable_id , rec.received_messageable_id].sort
    end
    times = @a.keys.length
    x = 0
    @body = []
    @email = []
    times.times do
    @body << @a.values[x].first.body
      if @a.values[x].first.sent_messageable_id == current_user.id
        @email << @users.find(@a.values[x].first.received_messageable_id).email

      else
        @email << @users.find(@a.values[x].first.sent_messageable_id).email
      end
    x += 1
    end
    @conversations = Hash[@body.zip @email]
  end

  def outbox
    @messages = current_user.sent_messages
  end

  def show
    raise
    puts @a
    put "looool"
    # @messages = current_user.messages.order("created_at ASC")
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
    @messages = current_user.messages.order("created_at ASC")
    @a = @messages.group_by do |rec|
      [rec.sent_messageable_id , rec.received_messageable_id].sort
    end
    user_id = User.where(email: params[:email_to]).first.id
    @a.keys.each_with_index do |key, index|
      if key.include? user_id
        @conversation = @a.values[index]
      end
    end
    if !@conversation.nil?
      if current_user.id == @conversation.first.sent_messageable_id
      else
      mark_as_read(@conversation)
      end
    end

    @message = Message.new
  end

  def create
      @email = params[:message][:sent_messageable_id]
      @to = User.where(email: @email).first
      current_user.send_message(@to, params[:message][:body])
  redirect_to new_message_path(email_to: "mt.monin@gmail.com")
  end

  def mark_as_read(message)
    message.each do |mess|
      mess.update(opened: true)
    end
  end
end
