class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :bio
      t.string :dob
      t.integer :books_count

      t.timestamps
    end
  end
end
