require 'spec_helper'

describe Approval::ApprovalRequestHistory do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    pending
    history = FactoryGirl.build(:approval_approval_request_history_1)
    expect(history).to be_valid
  end
end
