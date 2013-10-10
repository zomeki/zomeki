class CreateSurveyFormAnswers < ActiveRecord::Migration
  def change
    create_table :survey_form_answers do |t|
      t.belongs_to :form

      t.timestamps
    end
    add_index :survey_form_answers, :form_id
  end
end
