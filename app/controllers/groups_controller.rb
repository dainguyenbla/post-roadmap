class GroupsController < ApplicationController
  def index
    @groups = current_user.groups
  end

  def show
    if(!GroupsUser.find_by(user_id: current_user.id, group_id: params[:id]))
      redirect_to action: 'index'
    else
      @group = Group.find(params[:id])
      @posts = @group.posts.page params[:page]
      @users = @group.users
      @post = Post.new
    end
  end

  def new
    @group = Group.new
  end

  def create
    @group = @current_user.groups.new(group_params)
    if @group.save
      @group.add_user(@current_user.id)
      redirect_to @group
    else
      render 'new'
    end
  end

  def add_member
    @group = Group.find_by_code params[:group][:code]
    if(@group)
      @group.add_user(@current_user.id)
      redirect_to @group
    else
      @error = 'Group is not found!'
      redirect_to action: 'index'
    end
  end
  
  private

  def group_params
    params.require(:group).permit(:name)
  end
end
