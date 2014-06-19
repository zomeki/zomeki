class AddSiteIdToCmsKanaDictionaries < ActiveRecord::Migration
  def change
    add_column :cms_kana_dictionaries, :site_id, :integer, :after => :unid
    site = Cms::Site.where(state: 'public').find(:first, :order => :id)
    Cms::KanaDictionary.update_all(site_id: site.id)
  end
end
