class AddIndexLinkToSurveyForms < ActiveRecord::Migration
  def change
    add_column :survey_forms, :index_link, :string
  end
end
