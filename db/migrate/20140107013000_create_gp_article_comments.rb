class CreateGpArticleComments < ActiveRecord::Migration
  def change
    create_table :gp_article_comments do |t|
      t.belongs_to :doc
      t.string :state
      t.string :author_name
      t.string :author_email
      t.string :author_url
      t.string :remote_addr
      t.string :user_agent
      t.text :body
      t.datetime :posted_at

      t.timestamps
    end
    add_index :gp_article_comments, :doc_id
  end
end
