class AddConfirmationToSurveyForms < ActiveRecord::Migration
  def change
    add_column :survey_forms, :confirmation, :boolean
  end
end
