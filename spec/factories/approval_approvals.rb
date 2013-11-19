FactoryGirl.define do
  factory :approval_approval_1, class: 'Approval::Approval' do
    association :approval_flow, :factory => :approval_approval_flow_1
    index 0
  end
end
