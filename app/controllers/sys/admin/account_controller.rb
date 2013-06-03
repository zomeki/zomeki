# encoding: utf-8
class Sys::Admin::AccountController < Sys::Controller::Admin::Base
  def login
    admin_uri = "/#{ZomekiCMS::ADMIN_URL_PREFIX}"
    
    return redirect_to(admin_uri) if logged_in?
    
    @uri = params[:uri] || cookies[:sys_login_referrer] || admin_uri
    @uri = @uri.gsub(/^http:\/\/[^\/]+/, '')
    return unless request.post?
    
    unless new_login(params[:account], params[:password])
      flash[:alert] = 'ユーザＩＤ・パスワードを正しく入力してください。'
      respond_to do |format|
        format.html { render }
        format.xml  { render(:xml => '<errors />') }
      end
      return true
    end
    
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = {
        :value   => self.current_user.remember_token,
        :expires => self.current_user.remember_token_expires_at
      }
    end

    cookies.delete :sys_login_referrer

    # システム管理者以外は所属サイトにのみログインできる
    unless current_user.root? || current_user.sites.include?(Core.site)
      logger.warn %Q!"#{current_user.name}" doesn't belong to "#{Core.site.name}", logged out.!
      logout
      flash[:alert] = 'ユーザＩＤ・パスワードを正しく入力してください。'
      return
    end

    respond_to do |format|
      format.html { redirect_to @uri }
      format.xml  { render(:xml => current_user.to_xml) }
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_to('action' => 'login')
  end
  
  def info
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => Core.user.to_xml(:root => 'item', :include => :groups) }
    end
  end

  def new_password_reminder
  end

  def create_password_reminder
    if params[:account].blank? || params[:email].blank?
      redirect_to new_admin_password_reminder_url, alert: 'ユーザIDと登録されているメールアドレスを<br />入力してください。'.html_safe
      return
    end

    user = Sys::User.where(account: params[:account], email: params[:email]).first

    if (email = user.try(:email))
      token = Util::String::Token.generate_unique_token(Sys::User, :reset_password_token)
      user.update_column(:reset_password_token_expires_at, 12.hours.since)
      user.update_column(:reset_password_token, token)

      body = <<-EOT
パスワード変更を受け付けました。12時間以内に下記URLから変更を行ってください。

#{edit_admin_password_url(token: token)}
      EOT

      send_mail('noreply', email, "【#{Core.site.try(:name).presence || 'ZOMEKI'}】パスワード再設定", body)
    end

    redirect_to admin_login_url, notice: 'メールにてパスワード再設定手順をお送りしました。'
  end

  def edit_password
    @token = params[:token]

    users = Sys::User.arel_table
    user = Sys::User.where(users[:reset_password_token].eq(@token).and(users[:reset_password_token_expires_at].gt(Time.now))).first

    redirect_to admin_login_url, alert: 'URLが正しくないか再設定期限が切れています。' unless user
  end

  def update_password
    @token = params[:token]

    users = Sys::User.arel_table
    user = Sys::User.where(users[:reset_password_token].eq(@token).and(users[:reset_password_token_expires_at].gt(Time.now))).first

    unless user
      redirect_to admin_login_url, alert: 'URLが正しくないか再設定期限を過ぎています。'
    else
      password = params[:password]
      password_confirmation = params[:password_confirmation]

      if password.blank? || password_confirmation.blank?
        flash[:alert] = 'パスワードを入力してください。'
        render :edit_password
      elsif password == password_confirmation
        user.update_column(:reset_password_token_expires_at, nil)
        user.update_column(:reset_password_token, nil)
        user.update_column(:password, password)
        redirect_to admin_login_url, notice: 'パスワードを再設定しました。'
      else
        flash[:alert] = 'パスワードが一致しません。'
        render :edit_password
      end
    end
  end
end
