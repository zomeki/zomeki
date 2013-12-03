FactoryGirl.define do
  factory :sns_share_account_1, :class => 'SnsShare::Account' do
    association :content, :factory => :sns_share_content_account_1
    provider 'facebook'
  end
end
