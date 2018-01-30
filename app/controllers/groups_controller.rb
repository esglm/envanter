class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.page(params[:page])
    authorize @groups
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @debits = @group.debits.page(params[:page])
  end

  # GET /groups/new
  def new
    @group = Group.new
    authorize @group
  end

  # GET /groups/1/edit
  def edit; end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    respond_to do |format|
      if @group.save
        format.html do
          redirect_to @group, notice: t(:created, model: t(:group))
        end
        format.json { render :index, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: t(:updated, model: t(:group)) }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    return redirect_to groups_path, alert: t(:destroy_error) unless
    @group.destroy

    respond_to do |format|
      format.html do
        redirect_to groups_url, notice: t(:destroyed, model: t(:group))
      end
      format.json { head :no_content }
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
    authorize @group
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
