class CreateSurveyForms < ActiveRecord::Migration
  def change
    create_table :survey_forms do |t|
      t.integer    :unid
      t.belongs_to :content

      t.string :title

      t.timestamps
    end
    add_index :survey_forms, :content_id
  end
end
