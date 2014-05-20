class AddFormTextMaxLengthToSurveyQuestions < ActiveRecord::Migration
  def change
    add_column :survey_questions, :form_text_max_length, :integer
  end
end
