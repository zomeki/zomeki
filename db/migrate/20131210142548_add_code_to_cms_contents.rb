class AddCodeToCmsContents < ActiveRecord::Migration
  def up
    add_column :cms_contents, :code, :string
    Cms::Content.all.each{|c| c.update_column(:code, "C#{c.id}") }
  end

  def down
    remove_column :cms_contents, :code
  end
end
