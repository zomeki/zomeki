require 'spec_helper'

describe Survey::Answer do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    answer = FactoryGirl.build(:survey_answer_1)
    expect(answer).to be_valid
  end

  it 'is invalid without a form_answer' do
    answer = FactoryGirl.build(:survey_answer_1, form_answer_id: nil)
    expect(answer).to have(1).error_on(:form_answer_id)
  end

  it 'is invalid without a question' do
    answer = FactoryGirl.build(:survey_answer_1, question_id: nil)
    expect(answer).to have(1).error_on(:question_id)
  end
end
