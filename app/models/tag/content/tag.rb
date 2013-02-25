# encoding: utf-8
class Tag::Content::Tag < Cms::Content
  default_scope where(model: 'Tag::Tag')

  has_many :tags, :foreign_key => :content_id, :class_name => 'Tag::Tag', :order => 'last_tagged_at DESC', :dependent => :destroy

  before_create :set_default_settings

  def tag_node
    return @tag_node if @tag_node
    @tag_node = Cms::Node.where(state: 'public', content_id: id, model: 'Tag::Tag').order(:id).first
  end

  def list_style
    setting_value(:list_style) || ''
  end

  def date_style
    setting_value(:date_style) || ''
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title(@date @group)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
  end
end
