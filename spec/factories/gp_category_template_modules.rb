# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gp_category_template_module_1, :class => 'GpCategory::TemplateModule' do
    content_id 1
    name 'template_module_one'
    title 'ひとつめのテンプレートモジュール'
  end
end
