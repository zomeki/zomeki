class DropPublicBbsBoards < ActiveRecord::Migration
  def up
    drop_table :public_bbs_boards
  end

  def down
    create_table :public_bbs_boards do |t|
      t.integer :unid
      t.references :content
      t.string :state

      t.string :title

      t.timestamps
    end
    add_index :public_bbs_boards, :content_id
  end
end
