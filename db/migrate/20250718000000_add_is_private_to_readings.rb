class AddIsPrivateToReadings < ActiveRecord::Migration[7.1]
  def change
    add_column :readings, :is_private, :boolean, default: false
  end
end
