# rubocop:disable RSpec/AnyInstance
require 'rails_helper'

describe PaymentsController, type: :controller do
  describe 'GET callback' do
    let(:user) { FactoryBot.create(:user) }
    let(:payment) do
      FactoryBot.build(:payment)
    end

    describe 'handles paid payment' do
      let(:payment) { FactoryBot.create(:payment, status: 'open', user: user, amount: '22.00') }
      let(:request) { get :callback, params: { id: payment.id } }

      let(:mollie) { instance_double(Mollie::Payment) }

      before do
        allow_any_instance_of(Payment).to receive(:mollie_payment).and_return(mollie)
        allow(mollie).to receive(:status).and_return(:paid)
        allow(mollie).to receive(:paid?).and_return(true)

        request
        payment.reload
      end

      it { expect(payment.status).to eq 'paid' }
    end

    describe 'handles open payment' do
      let(:payment) { FactoryBot.create(:payment, status: 'open', user: user, amount: '22.00') }
      let(:request) { get :callback, params: { id: payment.id } }

      let(:mollie) { instance_double(Mollie::Payment) }

      before do
        allow_any_instance_of(Payment).to receive(:mollie_payment).and_return(mollie)
        allow(mollie).to receive(:status).and_return(:open)
        allow(mollie).to receive(:paid?).and_return(false)

        request
        payment.reload
      end

      it { expect(payment.status).to eq 'open' }
    end
  end
end
# rubocop:enable RSpec/AnyInstance
