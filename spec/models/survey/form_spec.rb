require 'spec_helper'

describe Survey::Form do
  before do
    Core.user = FactoryGirl.build(:sys_user_system_admin)
    Core.user_group = Core.user.group
  end

  it 'has a valid factory' do
    form = FactoryGirl.build(:survey_form_1)
    expect(form).to be_valid
  end

  it 'is invalid without a title' do
    form = FactoryGirl.build(:survey_form_1, title: nil)
    expect(form).to have(1).error_on(:title)
  end
end
