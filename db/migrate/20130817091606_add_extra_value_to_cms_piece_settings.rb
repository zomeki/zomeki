class AddExtraValueToCmsPieceSettings < ActiveRecord::Migration
  def change
    add_column :cms_piece_settings, :extra_value, :text
  end
end
