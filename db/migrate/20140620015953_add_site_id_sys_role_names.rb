class AddSiteIdSysRoleNames < ActiveRecord::Migration
  def change
    add_column :sys_role_names, :site_id, :integer, :after => :id

    site = Cms::Site.where(state: 'public').find(:first, :order => :id)
    Sys::RoleName.all.each do |role|
      item = Sys::ObjectPrivilege.new
      item.and :role_id, role.id
      joins = ["INNER JOIN cms_concepts ON cms_concepts.unid = sys_object_privileges.item_unid"]
      items = item.find(:all, :group => :item_unid, :joins => joins, :order => :id)
      items.each do |i|
        unless i.concept.blank?
          role.update_column(:site_id, i.concept.site_id)
          break;
        end
      end

      if role.site_id.blank?
        role.update_column(:site_id, site.id)
      end
      
    end

  end
end
