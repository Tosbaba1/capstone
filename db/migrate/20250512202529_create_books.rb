class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :image_url
      t.integer :author_id
      t.text :description
      t.integer :page_length
      t.integer :year
      t.integer :library_id
      t.string :genre

      t.timestamps
    end
  end
end
