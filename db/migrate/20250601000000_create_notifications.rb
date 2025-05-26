class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.integer :recipient_id
      t.integer :actor_id
      t.string :action
      t.string :notifiable_type
      t.integer :notifiable_id
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
