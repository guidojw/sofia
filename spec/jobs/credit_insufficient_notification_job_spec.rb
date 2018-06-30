require 'rails_helper'

RSpec.describe CreditInsufficientNotificationJob, type: :job do
  describe '#perform' do
    let(:user) { FactoryBot.create(:user, name: 'Buddy Normal') }
    let(:negative_user) { FactoryBot.create(:user, name: 'Bro Negative', email: 'user@csvalpha.nl') }
    let(:negative_user_without_email) do
      FactoryBot.create(:user, name: 'Evil Emailless', email: nil, provider: 'some_external_source')
    end
    let(:user_without_email) do
      FactoryBot.create(:user, name: 'Good Emailless', email: nil, provider: 'some_external_source')
    end
    let(:treasurer) do
      FactoryBot.create(:user,
                        name: 'Sis Treasures', email: 'treasurer@csvalpha.nl',
                        roles: [FactoryBot.create(:role, role_type: :treasurer)])
    end
    let(:emails) { ActionMailer::Base.deliveries }

    subject(:job) { perform_enqueued_jobs { CreditInsufficientNotificationJob.perform_now } }

    before do
      ActionMailer::Base.deliveries = []
      user
      FactoryBot.create(:credit_mutation, user: negative_user, amount: -2)
      FactoryBot.create(:credit_mutation, user: negative_user_without_email, amount: -2)
      user_without_email
      treasurer
      job
    end

    it { expect(emails.size).to eq 2 }
    it { expect(emails.first.to.first).to eq negative_user.email }
    it { expect(emails.first.body.to_s).to include "http://testhost:1337/users/#{negative_user.id}" }
    it { expect(emails.second.to.first).to eq treasurer.email }
    it { expect(emails.second.body.to_s).to include negative_user_without_email.name }
    it { expect(emails.second.body.to_s).not_to include user_without_email.name }
  end
end
