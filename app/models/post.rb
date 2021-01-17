class Post < ApplicationRecord

  attribute :interval
  attribute :unit
  after_initialize :interval_cal

  has_many_attached :images
  has_many_attached :files
  has_many_attached :videos

  has_many :likes, as: :duty
  belongs_to :user
  belongs_to :group
  has_many :comments,  dependent: :destroy
  paginates_per 50

  def interval_cal
    if self.created_at
      interval_seconds = Time.now - self.created_at
      if (interval_seconds/1.days).floor > 1
        self.interval = self.created_at
        self.unit = ""
      elsif (interval_seconds/1.days).floor == 1
        self.interval = 1
        self.unit = "day"
      elsif (interval_seconds/1.hours).floor >= 1 && (interval_seconds/1.hours).floor < 24
        self.interval = (interval_seconds/1.hours).floor
        if (interval_seconds/1.hours).floor == 1
          self.unit = "hour"
        else
          self.unit = "hours"
        end
      elsif (interval_seconds/1.minutes).floor > 0
        self.interval = (interval_seconds/1.minutes).floor
        self.unit = "minutes"
      elsif (interval_seconds/1.minutes).floor == 0
        self.unit = "just"
      end
    else
      self.unit = "just"
    end
  end

  def broadcast_post user
    PostBroadcastJob.perform_later self, user
  end

  def get_posts_from_users users, page
    where(user: users).order(created_at: :desc).page page
  end

end
