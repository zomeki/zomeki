require 'spec_helper'

describe Approval::ApprovalFlow do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    approval_flow = FactoryGirl.build(:approval_approval_flow_1)
    expect(approval_flow).to be_valid
  end

  it 'is invalid without a title' do
    approval_flow = FactoryGirl.build(:approval_approval_flow_1, title: nil)
    expect(approval_flow).to have(1).error_on(:title)
  end
end
