class AddProgressAndReviewToReadings < ActiveRecord::Migration[7.1]
  def change
    add_column :readings, :progress, :integer
    add_column :readings, :review, :text
  end
end
