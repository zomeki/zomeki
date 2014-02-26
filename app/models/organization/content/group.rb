class Organization::Content::Group < Cms::Content
  default_scope where(model: 'Organization::Group')

  has_many :groups, :foreign_key => :content_id, :class_name => 'Organization::Group', :dependent => :destroy

  def refresh_groups
    return unless root_sys_group

    root_sys_group.children.each do |child|
      copy_from_sys_group(child)
    end

    groups.each do |group|
      group.destroy if group.sys_group.nil?
    end
  end

  def root_sys_group
    return unless Core.site
    belongings = Cms::SiteBelonging.arel_table
    Sys::Group.joins(:site_belongings).where(belongings[:site_id].eq(Core.site.id))
              .where(parent_id: 0, level_no: 1).first
  end

  private

  def copy_from_sys_group(sys_group)
    groups.where(sys_group_code: sys_group.code).first_or_create(name: sys_group.name_en)

    sys_group.children.each do |child|
      copy_from_sys_group(child) unless child.children.empty?
    end
  end
end
