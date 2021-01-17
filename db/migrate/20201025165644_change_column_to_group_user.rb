class ChangeColumnToGroupUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :group_users, :user_id
    remove_column :group_users, :group_id

    add_reference :group_users, :user, foreign_key: true
    add_reference :group_users, :group, foreign_key: true
  end
end
