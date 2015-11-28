class User < ActiveRecord::Base
  has_many :photos

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 acts_as_messageable :table_name => "messages", # default 'messages'
                      :required   => :body,                  # default [:topic, :body]
                      :dependent  => :destroy,               # default :nullify
                      :group_messages => true               # default false
end
