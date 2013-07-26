# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :valid_category, :class => 'PublicBbs::Category' do
    unid 1
    state 'closed'
    concept_id 1
    content_id 1
    layout_id 1

    level_no 0
    sort_no 1
    parent_id 0
    name 'hoge'
    title 'ほげ'
  end
end
