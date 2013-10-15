class AddOpenedAtAndClosedAtToSurveyForms < ActiveRecord::Migration
  def change
    add_column :survey_forms, :opened_at, :datetime
    add_column :survey_forms, :closed_at, :datetime
  end
end
