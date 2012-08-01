class CreatePublicBbsThreads < ActiveRecord::Migration
  def change
    create_table :public_bbs_threads do |t|
      t.integer :unid
      t.references :content
      t.string :state

      t.references :user
      t.string :title
      t.text :body

      t.timestamps
    end
    add_index :public_bbs_threads, :content_id
    add_index :public_bbs_threads, :user_id
  end
end
