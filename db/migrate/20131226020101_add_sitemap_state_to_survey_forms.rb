class AddSitemapStateToSurveyForms < ActiveRecord::Migration
  def change
    add_column :survey_forms, :sitemap_state, :string
  end
end
