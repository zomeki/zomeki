FactoryGirl.define do
  factory :approval_assignment_1, class: 'Approval::Assignment' do
    association :assignable, :factory => :approval_approval_1
    association :user, :factory => :sys_user_system_admin
  end
end
