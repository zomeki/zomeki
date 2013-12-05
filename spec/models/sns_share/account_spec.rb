require 'spec_helper'

describe SnsShare::Account do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    account = FactoryGirl.build(:sns_share_account_1)
    expect(account).to be_valid
  end

  it 'is invalid without a provider' do
    account = FactoryGirl.build(:sns_share_account_2, provider: nil)
    expect(account).to have(1).error_on(:provider)
  end
end
