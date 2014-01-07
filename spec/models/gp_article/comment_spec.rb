require 'spec_helper'

describe GpArticle::Comment do
  it 'has a valid factory' do
    comment = FactoryGirl.build(:gp_article_comment_1)
    expect(comment).to be_valid
  end

  it 'is invalid without a doc' do
    comment = FactoryGirl.build(:gp_article_comment_1, doc: nil)
    expect(comment).to have(1).error_on(:doc_id)
  end

  it 'is invalid without a state' do
    comment = FactoryGirl.build(:gp_article_comment_1, state: nil)
    expect(comment).to have(1).error_on(:state)
  end
end
