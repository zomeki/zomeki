require 'spec_helper'

describe Approval::Approval do
  it 'has a valid factory' do
    pending
    approval = FactoryGirl.build(:approval_approval_1)
    expect(approval).to be_valid
  end

  it 'is invalid without a index' do
    pending
    approval = FactoryGirl.build(:approval_approval_1, index: nil)
    expect(approval).to have(1).error_on(:index)
  end
end
