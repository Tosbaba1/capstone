class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.integer :creator_id
      t.text :content
      t.integer :book_id
      t.integer :likes_count
      t.integer :comments_count

      t.timestamps
    end
  end
end
