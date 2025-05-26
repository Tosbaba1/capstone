class AddBannerToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :banner, :string
  end
end
