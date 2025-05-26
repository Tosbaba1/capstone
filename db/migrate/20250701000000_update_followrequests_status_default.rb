class UpdateFollowrequestsStatusDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :followrequests, :status, from: nil, to: 'pending'
  end
end
