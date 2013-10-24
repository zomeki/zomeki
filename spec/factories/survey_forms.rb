FactoryGirl.define do
  factory :survey_form_1, class: 'Survey::Form' do
    association :content, :factory => :survey_content_form_1
    name 'form1'
    title '汎用アンケートのフォームその１'
  end
end
