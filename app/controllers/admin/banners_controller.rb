class Admin::BannersController < ApplicationController
  before_action :set_banner, only: [:edit, :update, :destroy]
  before_action :authenticate_user! # если ты используешь Devise и хочешь ограничить

  def index
    @banners = Banner.all
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      redirect_to admin_banners_path, notice: 'Баннер создан'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @banner.update(banner_params)
      redirect_to admin_banners_path, notice: 'Баннер обновлён'
    else
      render :edit
    end
  end

  def destroy
    @banner.destroy
    redirect_to admin_banners_path, notice: 'Баннер удалён'
  end

  private

  def set_banner
    @banner = Banner.find(params[:id])
  end

  def banner_params
    params.require(:banner).permit(:title, :subtitle, :link, :image)
  end
end
