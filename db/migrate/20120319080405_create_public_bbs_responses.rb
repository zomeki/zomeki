class CreatePublicBbsResponses < ActiveRecord::Migration
  def change
    create_table :public_bbs_responses do |t|
      t.integer :unid
      t.references :content
      t.string :state

      t.references :thread
      t.references :user
      t.string :title
      t.text :body

      t.timestamps
    end
    add_index :public_bbs_responses, :content_id
    add_index :public_bbs_responses, :thread_id
    add_index :public_bbs_responses, :user_id
  end
end
