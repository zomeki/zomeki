class CreateSurveyFormAnswers < ActiveRecord::Migration
  def change
    create_table :survey_form_answers do |t|
      t.belongs_to :form
      t.string :answered_url
      t.string :remote_addr
      t.string :user_agent

      t.timestamps
    end
    add_index :survey_form_answers, :form_id
  end
end
