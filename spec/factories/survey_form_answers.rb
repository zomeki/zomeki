# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_form_answer_1, :class => 'Survey::FormAnswer' do
    association :form, :factory => :survey_form_2
  end
end
