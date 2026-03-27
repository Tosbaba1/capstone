class CreateSessionParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :session_participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :session, null: false, foreign_key: true
      t.datetime :join_time, null: false
      t.datetime :leave_time
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :session_participants, [:session_id, :user_id], unique: true
    add_index :session_participants, [:session_id, :leave_time]
  end
end
