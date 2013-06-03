# encoding: utf-8
FactoryGirl.define do
  factory :ad_banner_content_banner_1, class: AdBanner::Content::Banner do
    site_id 1
    concept_id 1
    state 'public'
    model 'AdBanner::Banner'
    name '広告バナー１'
    note '広告バナー１のメモ'
  end
end
