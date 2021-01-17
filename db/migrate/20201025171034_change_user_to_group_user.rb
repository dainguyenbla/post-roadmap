class ChangeUserToGroupUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :group_users, :group_id

    add_reference :group_users, :group, foreign_key: true
  end
end
