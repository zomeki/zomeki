FactoryGirl.define do
  factory :approval_assignment_1, class: 'Approval::Assignment' do
    association :user, :factory => :sys_user_system_admin
  end
end
