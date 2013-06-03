# encoding: utf-8
class AdBanner::Content::Banner < Cms::Content
  default_scope where(model: 'AdBanner::Banner')

  has_many :banners, :foreign_key => :content_id, :class_name => 'AdBanner::Banner', :dependent => :destroy
  has_many :groups, :foreign_key => :content_id, :class_name => 'AdBanner::Group', :dependent => :destroy

  def banner_node
    return @banner_node if @banner_node
    @banner_node = Cms::Node.where(state: 'public', content_id: id, model: 'AdBanner::Banner').order(:id).first
  end

  def groups_for_option
    groups.map {|g| [g.title, g.id] }
  end
end
