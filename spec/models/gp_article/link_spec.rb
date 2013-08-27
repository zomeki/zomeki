require 'spec_helper'

describe GpArticle::Link do
  it 'has a valid factory' do
    link = FactoryGirl.build(:gp_article_link_1)
    expect(link).to be_valid
  end

  it 'is invalid without a doc' do
    link = FactoryGirl.build(:gp_article_link_1, doc: nil)
    expect(link).to have(1).error_on(:doc_id)
  end

  it 'is invalid without a url' do
    link = FactoryGirl.build(:gp_article_link_1, url: nil)
    expect(link).to have(1).error_on(:url)
  end
end
