# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'admin@' + ENV['KNIFE_CLUB_URL'].to_s
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = User.find user.id
    uri = '/v1/password_resets/edit/@user.reset_password_token'
    @url = ENV['KNIFE_CLUB_URL'].to_s + uri
    mail(to: user.email,
         subject: 'Reset your password')
  end
end
