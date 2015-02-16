class AddQrcodeStateToGpArticleDocs < ActiveRecord::Migration
  def change
    add_column :gp_article_docs, :qrcode_state, :text
  end
end
