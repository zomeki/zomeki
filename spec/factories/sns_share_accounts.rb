FactoryGirl.define do
  factory :sns_share_account_1, :class => 'SnsShare::Account' do
    content_id 1
    provider 'facebook'
  end

  factory :sns_share_account_2, :class => 'SnsShare::Account' do
    content_id 1
    provider 'twitter'
  end
end
