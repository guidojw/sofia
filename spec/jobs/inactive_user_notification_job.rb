require 'rails_helper'

RSpec.describe InactiveUserNotificationJob, type: :job do
  describe '#perform' do
    let(:user) { FactoryBot.create(:user, name: 'Buddy Normal') }
    let(:old_active_user) { FactoryBot.create(:user, name: 'Buddy Old Active', created_at: 2.years.ago)}
    let(:negative_user) { FactoryBot.create(:user, name: 'Bro Negative', created_at: 2.years.ago) }
    let(:zero_user) { FactoryBot.create(:user, name: 'Bro Zero', created_at: 2.years.ago) }
    let(:treasurer) do
      FactoryBot.create(:user,
                        name: 'Sis Treasures', email: 'treasurer@csvalpha.nl',
                        roles: [FactoryBot.create(:role, role_type: :treasurer)])
    end
    let(:emails) { ActionMailer::Base.deliveries }

    subject(:job) { perform_enqueued_jobs { described_class.perform_now } }

    before do
      ActionMailer::Base.deliveries = []
      user
      FactoryBot.create(:credit_mutation, user: old_active_user, amount: -2)
      FactoryBot.create(:credit_mutation, user: negative_user, amount: -2, created_at: 1.year.ago)
      FactoryBot.create(:credit_mutation, user: zero_user, amount: 0, created_at: 1.year.ago)
      treasurer
      job

      zero_user.reload
      negative_user.reload
    end

    it { expect(emails.size).to eq 1 }
    it { expect(emails.first.to.first).to eq treasurer.email }
    it { expect(emails.first.body.to_s).to include negative_user.name }
    it { expect(emails.first.body.to_s).to include zero_user.name }
    it { expect(emails.first.body.to_s).not_to include user.name }
    it { expect(emails.first.body.to_s).not_to include old_active_user.name }

    it { expect(zero_user.deactivated).to eq true}
    it { expect(negative_user.deactivated).to eq false}
  end
end
