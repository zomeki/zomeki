FactoryGirl.define do
  factory :approval_approval_request_history_1, :class => 'Approval::ApprovalRequestHistory' do
    association :request, :factory => :approval_approval_request_1
    association :user, :factory => :sys_user_system_admin
    comment '承認履歴のコメント'
  end
end
