class Organization::Content::Group < Cms::Content
  HOLD_DOC_URL_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]

  default_scope where(model: 'Organization::Group')

  has_many :groups, :foreign_key => :content_id, :class_name => 'Organization::Group', :dependent => :destroy

  before_create :set_default_settings

  def public_node
    Cms::Node.where(state: 'public', content_id: id, model: 'Organization::Group').order(:id).first
  end

  def refresh_groups
    return unless root_sys_group

    root_sys_group.children.each do |child|
      next if (root_sys_group.sites & child.sites).empty?
      copy_from_sys_group(child)
    end

    groups.each do |group|
      group.destroy if group.sys_group.nil? ||
                       (root_sys_group.sites & group.sys_group.sites).empty?
    end
  end

  def root_sys_group
    return unless Core.site
    belongings = Cms::SiteBelonging.arel_table
    Sys::Group.joins(:site_belongings).where(belongings[:site_id].eq(Core.site.id))
              .where(parent_id: 0, level_no: 1).first
  end

  def find_group_by_path_from_root(path_from_root)
    group_names = path_from_root.split('/')
    return nil if group_names.empty?

    sys_group_codes = root_sys_group.children.pluck(:code)
    group = groups.where(sys_group_code: sys_group_codes, name: group_names.shift).first
    return nil unless group

    group_names.inject(group) {|result, item|
      result.children.where(name: item).first
    }
  end

  def hold_doc_url?
    setting_value(:hold_doc_url) == 'enabled'
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def time_style
    setting_value(:time_style).to_s
  end

  def num_docs
    setting_value(:num_docs).to_i
  end

  def gp_article_content_doc_ids
    YAML.load(setting_value(:gp_article_content_doc_ids).presence || '[]').map{|i| i.to_i }
  end

  private

  def copy_from_sys_group(sys_group)
    group = groups.where(sys_group_code: sys_group.code).first_or_create(name: sys_group.code)
    unless sys_group.children.empty?
      sys_group.children.each do |child|
        next if (sys_group.sites & child.sites).empty?
        copy_from_sys_group(child)
      end
    end
  end

  def set_default_settings
    in_settings[:hold_doc_url] = HOLD_DOC_URL_OPTIONS.last.last unless setting_value(:hold_doc_url)
    in_settings[:doc_style] = '@title@ (@publish_date@ @group@)' unless setting_value(:doc_style)
    in_settings[:date_style] = '%Y年%m月%d日' unless setting_value(:date_style)
    in_settings[:time_style] = '%H時%M分' unless setting_value(:time_style)
    in_settings[:num_docs] = '10' unless setting_value(:num_docs)
  end
end
