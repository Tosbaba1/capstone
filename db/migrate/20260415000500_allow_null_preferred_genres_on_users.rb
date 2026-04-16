class AllowNullPreferredGenresOnUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :preferred_genres, true
  end
end
