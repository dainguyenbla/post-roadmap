class CommentsController < ApplicationController
  def create
    
    @comment = current_user.comments.new comment_params
    respond_to do |format|
      if @comment.save
        @comment.comment_broadcast current_user
        @like = Like.new
        post = @comment.post
        if post.user != current_user
          @notification = Notification.create_notification 3, post.user.id,\
            current_user.id, post.id, @comment.id
          count = post.user.notifications.where(isSeen: false).count
          BroadcastNoticeJob.perform_now post.user, count, @notification
        end
        format.js 
      else
        format.js
      end
    end
  end

  def edit
    @comment = Comment.find_by id: params[:id]
    if @comment
      respond_to do |format|
        format.js
      end
    end
  end

  def update
    @comment = Comment.find_by id: params[:id]
    
    if @comment.update_attributes comment_params
      @like = Like.new
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @comment = Comment.find_by id: params[:id]
    if @comment && @comment.destroy
      respond_to do |format|
        format.js
      end

    else
    end
  end
  private
  def comment_params
    params[:comment].permit!
  end
end
