class CreateSurveyForms < ActiveRecord::Migration
  def change
    create_table :survey_forms do |t|
      t.integer    :unid
      t.belongs_to :content

      t.string     :state
      t.string     :name
      t.string     :title
      t.text       :upper_text
      t.text       :lower_text

      t.timestamps
    end
    add_index :survey_forms, :content_id
  end
end
