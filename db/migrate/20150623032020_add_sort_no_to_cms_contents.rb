class AddSortNoToCmsContents < ActiveRecord::Migration
  def change
    add_column :cms_contents, :sort_no, :integer
  end
end
