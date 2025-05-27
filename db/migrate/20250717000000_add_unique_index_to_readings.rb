class AddUniqueIndexToReadings < ActiveRecord::Migration[7.1]
  def change
    add_index :readings, [:user_id, :book_id], unique: true
  end
end
