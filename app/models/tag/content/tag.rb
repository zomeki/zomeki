# encoding: utf-8
class Tag::Content::Tag < Cms::Content
  default_scope where(model: 'Tag::Tag')

  has_many :tags, :foreign_key => :content_id, :class_name => 'Tag::Tag', :order => 'last_tagged_at DESC', :dependent => :destroy

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
end
