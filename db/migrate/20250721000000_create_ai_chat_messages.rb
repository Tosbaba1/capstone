class CreateAiChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_chat_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.text :content

      t.timestamps
    end
  end
end
