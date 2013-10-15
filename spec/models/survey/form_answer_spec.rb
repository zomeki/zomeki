require 'spec_helper'

describe Survey::FormAnswer do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    answer = FactoryGirl.build(:survey_form_answer_1)
    expect(answer).to be_valid
  end

  it 'is invalid without a form' do
    answer = FactoryGirl.build(:survey_form_answer_1, form: nil)
    expect(answer).to have(1).error_on(:form_id)
  end
end
