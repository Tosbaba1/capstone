class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.references :host_user, null: false, foreign_key: { to_table: :users }
      t.integer :duration, null: false
      t.string :mode, null: false, default: "silent"
      t.string :status, null: false, default: "NOT_STARTED"

      t.timestamps
    end

    add_index :sessions, :status
  end
end
