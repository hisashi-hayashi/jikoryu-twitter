class ApplicationController < ActionController::Base
  def current_user
    return unless session[:user_id]
    @current_user ||= User.where(id: session[:user_id]).first
  end

  def login?
    current_user.present?
  end
  helper_method :login?

  def admin?
    current_user.try(:admin_flg)
  end
  helper_method :admin?

  def check_admin_and_redirect_login_path
    return if login? && admin?
    flash[:alert] = 'ログインしてください。'
    redirect_to(new_login_path)
  end

  def check_login_and_redirect_login_path
    return if login?
    flash[:alert] = 'ログインしてください。'
    redirect_to(new_login_path)
  end
end
