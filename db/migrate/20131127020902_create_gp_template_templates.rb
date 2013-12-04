class CreateGpTemplateTemplates < ActiveRecord::Migration
  def change
    create_table :gp_template_templates do |t|
      t.integer    :unid
      t.references :content

      t.string     :state
      t.string     :title
      t.text       :body
      t.integer    :sort_no

      t.timestamps
    end
    add_index :gp_template_templates, :content_id
  end
end
