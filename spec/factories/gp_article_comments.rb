# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gp_article_comment_1, :class => 'GpArticle::Comment' do
    doc_id 1
    state 'closed'
    author_name 'やまだ たろう'
    author_email 'yamada@example.com'
    author_url 'http://example.com/'
    body 'こんにちは。これはコメントです。'
    posted_at '2014-01-07 10:30:00'
  end
end
