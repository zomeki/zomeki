class AddSortNoToSurveyForms < ActiveRecord::Migration
  def change
    add_column :survey_forms, :sort_no, :integer
  end
end
