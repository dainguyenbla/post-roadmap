class AddGroupToPost < ActiveRecord::Migration[5.2]
  def change
    add_reference :posts, :group
  end
end
