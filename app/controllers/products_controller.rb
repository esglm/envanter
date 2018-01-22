class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy debit_to_group debit_to_user]
  before_action :set_templates, only: %i[new edit]

  # GET /products
  # GET /products.json
  def index
    @products = Product.page(params[:page])
    authorize @products
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @debits = @product.debits.page(params[:page])
    @debit = @product.debits.find_by(status: true) # NOTE Supposition ~ Max 1 Record
    @groups = Group.all # FIXME !!!!! HIGH SYSTEM RESOURCE USAGE
    @users = User.all # FIXME !!!!! HIGH SYSTEM RESOURCE USAGE
  end

  # GET /products/new
  def new
    @product = Product.new
    authorize @product
  end

  # GET /products/1/edit
  def edit; end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    authorize @product
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: t(:created_message, something: t(:product)) }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: t(:updated_message, something: t(:product)) }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    begin
      @product.destroy
    rescue ActiveRecord::StatementInvalid
      return redirect_to products_path, alert: t(:destroy_error_message)
    end
    respond_to do |format|
      format.html { redirect_to products_url, notice: t(:destroyed_message, something: t(:product)) }
      format.json { head :no_content }
    end
  end

  # FIXME : "status: true" will be removed
  def debit_to_group
    return redirect_to @product, notice: t(:debit_save_error) if Group.find(params[:group_id]).nil?
    update_last_debit
    Debit.create(
      group_id: params[:group_id].to_i,
      status: true, product: @product
    )
    redirect_to @product, notice: t(:debit_save_success)
  end

  def debit_to_user
    return redirect_to @product, notice: t(:debit_save_error) if User.find(params[:user_id]).nil?
    update_last_debit
    Debit.create(
      user_id: params[:user_id].to_i,
      status: true, product: @product
    )
    redirect_to @product, notice: t(:debit_save_success)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
    authorize @product
  end

  def set_templates
    @templates = Template.all
  end

  def update_last_debit
    @last_debit = @product.debits.last
    return nil unless @last_debit && @last_debit.status
    @last_debit.update(end: Date.current, status: false)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(
      :name,
      :template_id,
      :company,
      :properties,
      :year,
      :warranty,
      :warranty_end
    )
  end
end
