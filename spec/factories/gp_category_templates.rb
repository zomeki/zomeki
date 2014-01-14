# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gp_category_template_1, :class => 'GpCategory::Template' do
    content_id 1
    name 'template_one'
    title 'ひとつめのテンプレート'
    body 'これはひとつめのテンプレートです。'
  end
end
