class AddFieldToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :photo, index: true, foreign_key: true
  end
end
