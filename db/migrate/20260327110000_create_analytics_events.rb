class CreateAnalyticsEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :session, null: true, foreign_key: true
      t.string :name, null: false
      t.datetime :occurred_at, null: false
      t.json :properties, null: false, default: {}

      t.timestamps
    end

    add_index :analytics_events, [:name, :occurred_at]
    add_index :analytics_events, [:user_id, :name, :occurred_at]
    add_index :analytics_events, [:session_id, :name]
  end
end
