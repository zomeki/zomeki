# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization_group, :class => 'Organization::Group' do
    name "MyString"
    title "MyString"
    title_en "MyString"
    code "MyString"
    sort_no 1
    state "MyString"
  end
end
