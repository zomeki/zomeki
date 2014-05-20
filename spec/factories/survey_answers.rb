# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey_answer_1, :class => 'Survey::Answer' do
    association :form_answer, :factory => :survey_form_answer_1
    association :question, :factory => :survey_question_1
  end
end
