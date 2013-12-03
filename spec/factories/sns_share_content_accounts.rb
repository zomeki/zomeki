FactoryGirl.define do
  time_now = Time.now
  factory :sns_share_content_account_1, :class => 'SnsShare::Content::Account' do
    site_id 1
    concept_id 1
    state 'public'
    model 'SnsShare::Account'
    name 'SNSシェア１'
    note 'SNSシェア１のメモ'
    created_at time_now
    updated_at time_now
  end
end
