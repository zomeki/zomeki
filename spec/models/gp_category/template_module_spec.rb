require 'spec_helper'

describe GpCategory::TemplateModule do
  it 'has a valid factory' do
    template_module = FactoryGirl.build(:gp_category_template_module_1)
    expect(template_module).to be_valid
  end

  it 'is invalid without a content' do
    template_module = FactoryGirl.build(:gp_category_template_module_1, content: nil)
    expect(template_module).to have(1).error_on(:content_id)
  end

  it 'is invalid without a name' do
    template_module = FactoryGirl.build(:gp_category_template_module_1, name: nil)
    expect(template_module).to have(1).error_on(:name)
  end

  it 'is invalid without a title' do
    template_module = FactoryGirl.build(:gp_category_template_module_1, title: nil)
    expect(template_module).to have(1).error_on(:title)
  end
end
