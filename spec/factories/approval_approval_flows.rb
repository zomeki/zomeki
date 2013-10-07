FactoryGirl.define do
  factory :approval_approval_flow_1, class: 'Approval::ApprovalFlow' do
    association :content, :factory => :approval_content_approval_flow_1
    title '承認フロー１番'
    sort_no 10
  end
end
