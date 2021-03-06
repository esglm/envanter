class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]
  before_action :set_users, only: %i[new edit]

  def index
    @groups = Group.page(params[:page])
    authorize @groups
  end

  def show
    @debits = @group.debits.page(params[:page])
  end

  def new
    @group = Group.new
    authorize @group
  end

  def edit; end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to @group, notice: t(:created, model: t(:group))
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t(:updated, model: t(:group))
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_url, notice: t(:destroyed, model: t(:group))
  end

  private

  def set_group
    @group = Group.find(params[:id])
    authorize @group
  end

  def set_users
    @users = User.all
  end

  def group_params
    params.require(:group).permit(:name, :coordinator_id)
  end
end
