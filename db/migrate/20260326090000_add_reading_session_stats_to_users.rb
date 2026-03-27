class AddReadingSessionStatsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_active, :datetime
    add_column :users, :total_reading_time, :integer, default: 0, null: false
    add_column :users, :sessions_completed, :integer, default: 0, null: false
  end
end
