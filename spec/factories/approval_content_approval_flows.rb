FactoryGirl.define do
  factory :approval_content_approval_flow_1, class: 'Approval::Content::ApprovalFlow' do
    site_id 1
    concept_id 1
    state 'public'
    model 'Approval::ApprovalFlow'
    name '承認フロー１'
    note '承認フロー１のメモ'
  end
end
