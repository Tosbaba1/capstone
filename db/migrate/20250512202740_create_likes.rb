class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.integer :post_id
      t.integer :liked_id

      t.timestamps
    end
  end
end
