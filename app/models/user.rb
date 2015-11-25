class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 acts_as_messageable :table_name => "messages", # default 'messages'
                      :required   => :body,                  # default [:topic, :body]
                      :dependent  => :destroy,               # default :nullify
                      :group_messages => true               # default false
end
