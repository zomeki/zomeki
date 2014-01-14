require 'spec_helper'

describe GpCategory::Template do
  it 'has a valid factory' do
    template = FactoryGirl.build(:gp_category_template_1)
    expect(template).to be_valid
  end

  it 'is invalid without a content' do
    template = FactoryGirl.build(:gp_category_template_1, content: nil)
    expect(template).to have(1).error_on(:content_id)
  end

  it 'is invalid without a name' do
    template = FactoryGirl.build(:gp_category_template_1, name: nil)
    expect(template).to have(1).error_on(:name)
  end

  it 'is invalid without a title' do
    template = FactoryGirl.build(:gp_category_template_1, title: nil)
    expect(template).to have(1).error_on(:title)
  end
end
