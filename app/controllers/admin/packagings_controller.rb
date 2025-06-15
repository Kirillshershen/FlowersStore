class Admin::PackagingsController < ApplicationController

  before_action :set_packaging, only: %i[show edit update destroy]

  def index
    @packagings = Packaging.order(created_at: :desc)
  end

    def new
      @packaging = Packaging.new
    end
def show
  # @packaging уже установлен через set_packaging
end

  def create
    @packaging = Packaging.new(packaging_params)
    if @packaging.save
      redirect_to admin_packagings_path, notice: 'Упаковка создана'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @packaging.update(packaging_params)
      redirect_to admin_packagings_path, notice: 'Упаковка обновлена'
    else
      render :edit
    end
  end

  def destroy
    @packaging.destroy
    redirect_to admin_packagings_path, notice: 'Упаковка удалена'
  end

  private

  def set_packaging
    @packaging = Packaging.find(params[:id])
  end

  def packaging_params
    params.require(:packaging).permit(:name, :price)
  end
end
