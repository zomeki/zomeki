# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tool_convert_setting, :class => 'Tool::ConvertSetting' do
    site_url "MyString"
    title_tag "MyText"
    body_tag "MyText"
  end
end
