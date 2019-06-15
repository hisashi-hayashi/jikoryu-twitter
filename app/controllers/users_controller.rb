class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    return render :new if @user.invalid?

    @user.save
    flash[:notice] = '登録が完了しました。'
    redirect_to action: :index
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.assign_attributes(user_params)
    return render :edit if @user.invalid?

    @user.save
    flash[:notice] = '更新が完了しました。'
    redirect_to action: :index
  end

  def destroy
    begin
      current_user.destroy
    rescue ActiveRecord::RecordNotFound; end

    flash[:notice] = '削除が完了しました。'
    redirect_to action: :index
  end

  private

  def current_user
    User.find(params.permit(:id)[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :crypted_password)
  end
end
