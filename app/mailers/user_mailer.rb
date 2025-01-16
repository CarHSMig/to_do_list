# frozen_string_literal: true

class UserMailer < Devise::Mailer
  include MailerHelper

  default template_path: 'users/mailer'
  default from: 'todo@example.com'
  layout 'layouts/mailer'
  helper 'mailer'

  def welcome_reset_password_instructions(user)
    @user = user
    @token = @user.send(:set_reset_password_token)
    @reset_password_url = mount_url("#{default_redirect_url}/new-password", reset_password_token: @token)
    mail(to: user.email, subject: I18n.t('mailer.welcome_reset_password_instructions.subject'))
  end

  def reset_password_instructions(user, _opts = {})
    @user = user
    @token = @user.send(:set_reset_password_token)
    @reset_password_url = mount_url("#{default_redirect_url}/reset-password", reset_password_token: @token)
    mail(to: user.email, subject: I18n.t('mailer.reset_password_instructions.subject'))
  end

  def unlock_instructions(user, _opts = {})
    @user = user
    @token = @user.send(:set_reset_password_token)
    @reset_password_url = mount_url("#{default_redirect_url}/reset-password", reset_password_token: @token)
    mail(to: user.email, subject: I18n.t('mailer.unlock_instructions.subject'))
  end

  private

  def default_redirect_url
    Rails.application.config.urls[:api_url]
  end
end
