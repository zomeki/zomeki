class RenameMobileToTerminalOnGpArticleDocs < ActiveRecord::Migration
  def up
    rename_column :gp_article_docs, :mobile_smart, :terminal_pc_or_smart_phone
    rename_column :gp_article_docs, :mobile_feature, :terminal_mobile
  end

  def down
    rename_column :gp_article_docs, :terminal_pc_or_smart_phone, :mobile_smart
    rename_column :gp_article_docs, :terminal_mobile, :mobile_feature
  end
end
