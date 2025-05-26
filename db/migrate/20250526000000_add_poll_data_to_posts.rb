class AddPollDataToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :poll_data, :jsonb
  end
end
