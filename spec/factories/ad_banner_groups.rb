# encoding: utf-8
FactoryGirl.define do
  factory :ad_banner_group_1, class: AdBanner::Group do
    name '1st group'
    title 'ひとつめのグループ'
    association :content, factory: :ad_banner_content_banner_1
  end
end
