class Sessions::OmniauthController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def create
    @user = User.from_omniauth(omniauth)

    if @user.persisted?
      # 检查用户是否已激活
      unless @user.activated?
        redirect_to sign_in_path, alert: "您的账号尚未激活,请等待管理员审核通过后再登录"
        return
      end
      
      session_record = @user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      redirect_to root_path, notice: "成功使用 #{omniauth.provider.humanize} 登录"
    else
      flash[:alert] = handle_password_errors(@user)
      redirect_to sign_in_path
    end
  end

  def failure
    error_type = params[:message] || request.env['omniauth.error.type']

    error_message = case error_type.to_s
    when 'access_denied'
      "授权已取消。如果您想登录，请重试。"
    when 'invalid_credentials'
      "提供的凭证无效。请检查您的信息并重试。"
    when 'timeout'
      "认证超时。请重试。"
    else
      "认证失败：#{error_type&.to_s&.humanize || '未知错误'}"
    end

    flash[:alert] = error_message
    redirect_to sign_in_path
  end

  private

  def omniauth
    request.env["omniauth.auth"]
  end
end
