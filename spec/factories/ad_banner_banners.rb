# encoding: utf-8
FactoryGirl.define do
  factory :ad_banner_banner_1, class: AdBanner::Banner do
    name 'sample_picture.jpg'
    title 'sample_picture'
    association :content, factory: :ad_banner_content_banner_1
    state 'public'
    advertiser '広告主株式会社'
    published_at 3.days.ago
    closed_at 4.days.since
  end
end
