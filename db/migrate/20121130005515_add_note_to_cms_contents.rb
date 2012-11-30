class AddNoteToCmsContents < ActiveRecord::Migration
  def change
    add_column :cms_contents, :note, :string
  end
end
