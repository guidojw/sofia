class InactiveUserMailer < ApplicationMailer
  def notification_mail(treasurer, inactive_users_with_credit, inactive_users_without_credit)
    @user = treasurer

    @inactive_users_with_credit = inactive_users_with_credit
    @inactive_users_without_credit = inactive_users_without_credit
    mail to: treasurer.email, subject: '[Belangrijk] Er zijn inactieve gebruikers in het streepsysteem'
  end
end
