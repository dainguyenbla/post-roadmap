class Like < ApplicationRecord
  belongs_to :user
  belongs_to :duty, polymorphic: true

  def like_post_comment_broadcast count, duty_type, duty_id
    LikeBroadcastJob.perform_now count, duty_type, duty_id
  end
end
