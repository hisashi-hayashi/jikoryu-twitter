class UsersController < ApplicationController
  before_action :check_admin_and_redirect_login_path, only: %i(index edit update destroy)

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
    redirect_to(new_login_path)
  end

  def edit
    @user = selected_user
  end

  def update
    @user = selected_user
    @user.assign_attributes(user_params)
    return render :edit if @user.invalid?

    @user.save
    flash[:notice] = '更新が完了しました。'
    redirect_to(users_path)
  end

  def destroy
    begin
      selected_user.destroy
    rescue ActiveRecord::RecordNotFound; end

    flash[:notice] = '削除が完了しました。'
    redirect_to(users_path)
  end

  private

  def selected_user
    User.find(params.permit(:id)[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
