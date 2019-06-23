class SessionsController < ApplicationController
  def new
    redirect_to(tweets_path) if login?
  end

  def create
    user = login(login_params[:email], login_params[:password])
    if user
      redirect_to(tweets_path)
    else
      flash[:alert] = 'ログインに失敗しました。'
      redirect_to(new_login_path)
    end
  end

  def destroy
    logout
    redirect_to(new_login_path)
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
