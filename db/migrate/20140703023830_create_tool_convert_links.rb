class CreateToolConvertLinks < ActiveRecord::Migration
  def up
    create_table :tool_convert_links do |t|
      t.belongs_to :concept
      t.belongs_to :linkable, polymorphic: true
      t.text       :urls
      t.text       :before_body, limit: 2147483647
      t.text       :after_body, limit: 2147483647
      t.timestamps
    end
  end

  def down
    drop_table :tool_convert_links
  end
end
