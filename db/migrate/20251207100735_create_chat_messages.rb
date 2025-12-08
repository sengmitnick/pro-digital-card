class CreateChatMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_messages do |t|
      t.references :chat_session
      t.string :role
      t.text :content


      t.timestamps
    end
  end
end
