# encoding: utf-8
FactoryGirl.define do
  factory :gp_article_link_1, class: 'GpArticle::Link' do
    doc_id 1
    body 'こちら'
    url 'http://example.com'
  end
end
