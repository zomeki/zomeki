require 'spec_helper'

describe Approval::Approval do
  it 'has a valid factory' do
    approval = FactoryGirl.build(:approval_approval_1)
    expect(approval).to be_valid
  end

  it 'is invalid without a number' do
    approval = FactoryGirl.build(:approval_approval_1, number: nil)
    expect(approval).to have(1).error_on(:number)
  end
end
