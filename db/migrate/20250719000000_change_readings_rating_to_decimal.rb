class ChangeReadingsRatingToDecimal < ActiveRecord::Migration[7.1]
  def change
    change_column :readings, :rating, :decimal, precision: 2, scale: 1
  end
end
