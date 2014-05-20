FactoryGirl.define do
  factory :approval_approval_request_1, :class => 'Approval::ApprovalRequest' do
    time_now = Time.now

    association :user, :factory => :sys_user_system_admin
    association :approvable, :factory => :survey_form_1
    association :approval_flow, :factory => :approval_approval_flow_1
    current_index 0
    created_at time_now
    updated_at time_now
  end
end
