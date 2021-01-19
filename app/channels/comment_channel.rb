class CommentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "comment_post_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    cmt = Comment.find_by id: data["comment"]["id"]
    html = CommentsController.render(partial: 'comments/comment', locals:{ comment: cmt, current_user: current_user})
    SelfUserBroadcastJob.perform_now current_user, html, data["post_id"], data["count"]
  end
end
