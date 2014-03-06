class AddEtceteraToCmsPieces < ActiveRecord::Migration
  def change
    add_column :cms_pieces, :etcetera, :text, :limit => 16777215
  end
end
