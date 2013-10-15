require 'spec_helper'

describe Survey::Question do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    question = FactoryGirl.build(:survey_question_1)
    expect(question).to be_valid
  end

  it 'is invalid without a title' do
    question = FactoryGirl.build(:survey_question_1, title: nil)
    expect(question).to have(1).error_on(:title)
  end

  it 'is invalid without a sort_no' do
    question = FactoryGirl.build(:survey_question_1, sort_no: nil)
    expect(question).to have(1).error_on(:sort_no)
  end
end
