class Photo < ActiveRecord::Base
  has_many :messages

  has_attached_file :image
  validates_attachment :image, :content_type => {:content_type => %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document)}

  # has_attached_file :document, styles: { medium: "300x300>", thumb: "100x100>" }
  # validates_attachment_content_type :document, content_type: /\Aimage\/.*\Z/
end
