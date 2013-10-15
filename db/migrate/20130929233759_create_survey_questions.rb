class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.belongs_to :form
      t.string     :state
      t.string     :title
      t.text       :description
      t.string     :form_type
      t.text       :form_options
      t.boolean    :required
      t.string     :style_attribute
      t.integer    :sort_no

      t.timestamps
    end
    add_index :survey_questions, :form_id
  end
end
