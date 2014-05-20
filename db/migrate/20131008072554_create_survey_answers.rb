class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.belongs_to :form_answer
      t.belongs_to :question

      t.text :content

      t.timestamps
    end
    add_index :survey_answers, :form_answer_id
    add_index :survey_answers, :question_id
  end
end
