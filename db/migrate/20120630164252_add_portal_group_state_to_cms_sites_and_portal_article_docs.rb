class AddPortalGroupStateToCmsSitesAndPortalArticleDocs < ActiveRecord::Migration
  def up
    add_column :cms_sites, :portal_group_state, :string
    add_column :portal_article_docs, :portal_group_state, :string

    Cms::Site.update_all("portal_group_state = 'visible'")
    PortalArticle::Doc.update_all("portal_group_state = 'visible'")
  end

  def down
    remove_column :cms_sites, :portal_group_state
    remove_column :portal_article_docs, :portal_group_state
  end
end
