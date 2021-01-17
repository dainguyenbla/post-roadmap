class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :authen
  has_one_attached :avatar
  has_many :posts
  has_many :comments
  has_many :likes

  has_many :followed_users, foreign_key: :follower_id, class_name: 'Follow'
  has_many :followees, through: :followed_users

  has_many :following_users, foreign_key: :followee_id, class_name: 'Follow'
  has_many :followers, through: :following_users

  has_many :requests, foreign_key: :res_user_id, class_name: 'ReqFriend'
  has_many :req_users, through: :requests

  has_many :respones, foreign_key: :req_user_id, class_name: 'ReqFriend'
  has_many :res_users, through: :respones

  has_many :current_users, foreign_key: :friend_id, class_name: 'Friend'
  has_many :currents, through: :current_users

  has_many :friend_users, foreign_key: :current_id, class_name: 'Friend'
  has_many :friends, through: :friend_users

  has_many :messages

  has_many :room_users
  has_many :usr_rooms, through: :room_users, source: :room

  has_many :notifications

  has_many :own_groups, :class_name => 'Group', :foreign_key => 'creator_id'

  has_and_belongs_to_many :groups

  attr_accessor :remember_token
  validates :name, :presence => { message: "Tên không được để trống"}
  VALID_PHONE_REGEX = /\b(0)+[2-9]+([0-9]{8})\b/
  validates :phone, presence: { message: "Số điện thoại không được để trống"}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "Email không được để trống!"}
  validates :email, allow_blank: true, length: { maximum: 250 },
    format: { with: VALID_EMAIL_REGEX, message: "Email không hợp lệ!" },
    uniqueness: { case_sensitive: false }
  validates :password, presence: { message: "Mật khẩu không được để trống!"},\
    if: :password_changed?
  validates :password, 
    length: { minimum: 8, message: "Mật khẩu phải có ít nhất 8 ký tự" }, 
    confirmation: { message: "Mật khẩu xác nhận không khớp!"}, if: :password_changed?
  validates_confirmation_of :password
  validates :password_confirmation,
    presence: { message: "Mật khẩu xác nhận không được để trống!" },
    if: :password_changed?

  before_save :downcase_email

  has_secure_password validations: false

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  def password_changed?
    !password.nil? or self.password_digest.nil? 
  end



  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute :remember_digest, nil
  end


    def downcase_email
      self.email = email.downcase
    end

 

# has_many :conversations
# has_many :co_rooms, through: :conversations, source: :room

# has_many :senders, foreign_key: :receive_id, class_name: 'Conversation'
# has_many :sends, through: :senders, source: :receive

# has_many :receivers, foreign_key: :send_id, class_name: 'Conversation'
# has_many :receives, through: :receivers, source: :send

  scope :search_user, -> (name) do
    where("name LIKE ?", "%#{name.strip}%")
  end

  def self.new_with_session params, session
    super.tap do |user|
      if data = session["devise.facebook_data"] &&
        session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def urlAvatar x, y, h, w
    self.update(image: Rails.application.routes.url_helpers.rails_representation_url(self.avatar.variant(combine_options:{:crop=>"#{w}x#{h}+#{x}+#{y}"}).processed, only_path: true))
  end

  def self.from_omniauth auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.image = auth.info.image
    end
  end


  def broadcast_send_req_friend res_user
    action = "send-req"
    NotifyReqFriendJob.perform_later self, res_user, action
  end

  def broadcast_delete_req_friend res_user
    action = "delete-req"
    NotifyReqFriendJob.perform_later self, res_user, action
  end

  def broadcast_accept_friend res_user
    action = "accept-friend"
    NotifyReqFriendJob.perform_later self, res_user, action
  end

  def broadcast_unfriend user
    action = "unfriend"
    NotifyReqFriendJob.perform_later self, user, action
  end

  def get_friend_count
    self.friends.count
  end


  def get_friend_list
    self.friends.limit(9)
  end

  def get_mutual_friends user
    self.friends.where(id: user.friends.pluck(:id))
  end

end
