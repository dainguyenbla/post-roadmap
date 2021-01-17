class Group < ApplicationRecord
  has_one :creator, :class_name => 'User', :foreign_key => 'id', :primary_key => 'creator_id'
  has_many :posts
  has_many :users
  has_and_belongs_to_many :users

  validates :name, presence: true

  before_create :add_code

  def add_code
    self.code = SecureRandom.hex[0..5]
  end

  def add_user id
    GroupsUser.find_or_create_by(user_id: id, group_id: self.id)
  end
end
