class AddCodeToCmsContents < ActiveRecord::Migration
  def change
    add_column :cms_contents, :code, :string
  end
end
