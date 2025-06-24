class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.all.order(created_at: :desc)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:notice] = "Данные пользователя обновлены"
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, 
      :last_name, 
      :phone, 
      :email, 
      :admin
    )
  end

  def require_admin
    unless current_user.admin?
      flash[:alert] = "Доступ запрещён"
      redirect_to root_path
    end
  end
end