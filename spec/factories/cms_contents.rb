# encoding: utf-8
FactoryGirl.define do
  factory :cms_content_map_marker_1, class: Cms::Content do
    site_id 1
    concept_id 1
    state 'public'
    model 'Map::Marker'
    name '地図マーカー１'
    note '地図マーカー１のメモ'
  end

  factory :cms_content_ad_banner_banner_1, class: Cms::Content do
    site_id 1
    concept_id 1
    state 'public'
    model 'AdBanner::Banner'
    name '広告バナー１'
    note '広告バナー１のメモ'
  end

  factory :cms_content_ad_banner_banner_2, class: Cms::Content do
    site_id 1
    concept_id 1
    state 'public'
    model 'AdBanner::Banner'
    name '広告バナー２'
    note '広告バナー２のメモ'
  end
end
