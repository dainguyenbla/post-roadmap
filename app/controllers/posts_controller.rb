class PostsController < ApplicationController
# before_action :authenticate_user!
      before_action :logged_in_user

  def index
   @post = Post.new
   @comment = Comment.new
   @like = Like.new
   followers = current_user.followers.pluck(:id)
   followers.push(current_user.id)
#   @posts = Post.get_posts_from_users followers, params[:page]
   @posts = Post.where(user: followers, group_id: nil).order(created_at: :desc).page params[:page]

   
#   @posts = @posts = Post.paginate(page: params[:page])
  end

  def edit 
    @post = Post.find_by id: params[:id]
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @post = Post.find_by id: params[:id]
    if @post
      @post.destroy
      respond_to do |format|
        format.js
      end
    end
      
  end

  def create
    @post = current_user.posts.new message_params
    respond_to do |format|
      if @post.save!
        @post.broadcast_post current_user
        format.js
      else
        format.js
      end
    end
  end
  
  def new
    @post = Post.new
    respond_to do |format|
      format.js
    end
  end

  def update
    @post = Post.find_by id: params[:id]
    if @post.update_attributes message_params
      @like = Like.new
      @comment = Comment.new
      respond_to do |format|
        format.js
      end
    end
  end

  def show
    @anc = params[:anc]
    @post = Post.find_by id: params[:id]
    respond_to do |format|
      format.js
      format.html
    end

  end
  
private
  def message_params
    params.require(:post).permit(:message, :group_id, images: [], files: [], videos: [])
  end
  def logged_in_user
    unless logged_in?
      store_location
      redirect_to new_auth_session_url
    end
  end

end
