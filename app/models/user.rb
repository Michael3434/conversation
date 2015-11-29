class User < ActiveRecord::Base
  has_many :photos

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 acts_as_messageable :table_name => "messages", # default 'messages'
                      :required   => :body,                  # default [:topic, :body]
                      :dependent  => :destroy,               # default :nullify
                      :group_messages => true               # default false


  # Returns the list of messages exchanged with another user
  def messages_with(user)
    messages.where("sent_messageable_id = :user_id or received_messageable_id = :user_id", user_id: user.id)
  end
end
