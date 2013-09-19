require 'spec_helper'

describe Approval::Assignment do
  it 'has a valid factory' do
    pending 'Approval is not created yet'
    assignment = FactoryGirl.build(:approval_assignment_1)
    expect(assignment).to be_valid
  end

  it 'is invalid without a approval' do
    assignment = FactoryGirl.build(:approval_assignment_1, approval_id: nil)
    expect(assignment).to have(1).error_on(:approval_id)
  end

  it 'is invalid without a user' do
    assignment = FactoryGirl.build(:approval_assignment_1, user_id: nil)
    expect(assignment).to have(1).error_on(:user_id)
  end
end
