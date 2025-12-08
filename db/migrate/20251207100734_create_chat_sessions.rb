class CreateChatSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :chat_sessions do |t|
      t.references :profile
      t.string :visitor_name
      t.string :visitor_email
      t.datetime :started_at
      t.datetime :ended_at


      t.timestamps
    end
  end
end
