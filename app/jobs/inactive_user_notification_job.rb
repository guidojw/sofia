class InactiveUserNotificationJob < ApplicationJob
  queue_as :default

  def perform
    inactive_users_without_credit.each do |u|
      u.update(deactivated: true)
    end

    User.treasurer.each do |treasurer|
      InactiveUserMailer.notification_mail(
        treasurer,
        inactive_users_with_credit.map(&:name),
        inactive_users_without_credit.map(&:name)
      ).deliver_later
    end
  end

  private

  def inactive_users
    # Select all users without orders and credit_mutations for a year
    @inactive_users ||= User.all.select do |u|
      u.created_at < deactivation_period &&
        (u.orders.empty? || u.orders.last.created_at <= deactivation_period) &&
        (u.credit_mutations.empty? || u.credit_mutations.last.created_at <= deactivation_period)
    end
  end

  def inactive_users_without_credit
    @inactive_user_without_credit ||= inactive_users.select { |u| u.credit.zero? }
  end

  def inactive_users_with_credit
    @inactive_user_with_credit ||= inactive_users.select { |u| !u.credit.zero? }
  end

  def deactivation_period
    1.year.ago
  end
end
