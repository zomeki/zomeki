class CreatePublicBbsTags < ActiveRecord::Migration
  def change
    create_table :public_bbs_tags, :force => true do |t|
      t.integer :unid

      t.string :name
      t.text :word

      t.timestamps
    end
  end
end
