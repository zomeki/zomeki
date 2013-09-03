class CreateCmsLinkCheckLogs < ActiveRecord::Migration
  def change
    create_table :cms_link_check_logs do |t|
      t.belongs_to :link_check
      t.belongs_to :link_checkable, polymorphic: true

      t.boolean :checked

      t.string :title
      t.string :body
      t.string :url
      t.integer :status
      t.string :reason
      t.boolean :result

      t.timestamps
    end
  end
end
