# Preview all emails at http://localhost:5000/rails/mailers/inactive_user_mailer
class InactiveUserMailerPreview < ActionMailer::Preview
  def notify_mail
    treasurer = FactoryBot.create(:user)
    inactive_users_with_credit = FactoryBot.create_list(:user, 3).map(&:name)
    inactive_users_without_credit = FactoryBot.create_list(:user, 5).map(&:name)

    InactiveUserMailer.notification_mail(treasurer, inactive_users_with_credit, inactive_users_without_credit)
  end
end
