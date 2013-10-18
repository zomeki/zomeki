class RemoveTextsFromSurveyForms < ActiveRecord::Migration
  def up
    remove_column :survey_forms, :upper_text
    remove_column :survey_forms, :lower_text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
