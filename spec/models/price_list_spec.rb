require 'rails_helper'

RSpec.describe PriceList, type: :model do
  subject(:price_list) { FactoryGirl.build_stubbed(:price_list) }

  describe '#valid' do
    it { expect(price_list).to be_valid }

    context 'when without a name' do
      subject(:price_list) { FactoryGirl.build_stubbed(:price_list, name: nil) }

      it { expect(price_list).not_to be_valid }
    end
  end

  describe '#product_price_for' do
    subject(:price_list) { FactoryGirl.create(:price_list) }

    let(:product) { FactoryGirl.create(:product) }

    before do
      FactoryGirl.create(:product_price, product: product, price_list: price_list, amount: 8)
    end

    it { expect(price_list.product_price_for(product).amount).to eq 8 }
  end
end
