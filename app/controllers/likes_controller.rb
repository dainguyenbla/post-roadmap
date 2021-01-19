class LikesController < ApplicationController
  def create
    @like = current_user.likes.new like_params
    @post = @like.duty
    @liked = @post.likes.find_by(user_id: current_user.id)

    respond_to do |format|
      if !@liked
        @like.save
        if @like.duty_type === "Post"
          post = @like.duty
          if post.user != current_user
            @notification = post.user.notifications.find_by event_id:2, sender_id: current_user.id, link:"/posts/#{post.id}"
          
            if @notification.nil?
              @notification = post.user.notifications.create event_id:2, sender_id: current_user.id, link:"/posts/#{post.id}"
              count = post.user.notifications.where(isSeen: false).count
              BroadcastNoticeJob.perform_now post.user, count, @notification
            end
          end
        elsif @like.duty_type === "Comment"
          comment = @like.duty
          if comment.user != current_user
            @notification = comment.user.notifications.find_by event_id:1, sender_id: current_user.id, link:"/posts/#{comment.post.id}?anc=cmt_#{@like.duty.id}"

            if @notification.nil?
              @notification = comment.user.notifications.create event_id:1, sender_id: current_user.id, link:"/posts/#{comment.post.id}?anc=cmt_#{@like.duty.id}"
              count = comment.user.notifications.where(isSeen: false).count
              BroadcastNoticeJob.perform_now comment.user, count, @notification
            end
          end
        end

        format.js
      else
        @liked.destroy
        format.js
      end
      @like.like_post_comment_broadcast(@post.likes.count, @like.duty_type, @post.id)

    end
  end

  private
  def like_params
    params[:like].permit!
  end
end
