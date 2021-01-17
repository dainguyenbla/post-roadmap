class Comment < ApplicationRecord
  attribute :unit
  attribute :interval
  after_initialize :interval_cal

  has_many :likes, as: :duty, dependent: :destroy
  belongs_to :post
  belongs_to :user

  def comment_broadcast c_user
    CommentBroadcastJob.perform_now self, c_user
  end
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
end
