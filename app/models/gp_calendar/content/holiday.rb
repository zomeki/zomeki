# encoding: utf-8
class GpCalendar::Content::Holiday < Cms::Content
  IMAGE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]

  default_scope where(model: 'GpCalendar::Holiday')

  has_many :holidays, :foreign_key => :content_id, :class_name => 'GpCalendar::Holiday', :dependent => :destroy

  def public_nodes
    nodes.public
  end

  def public_node
    public_nodes.order(:id).first
  end

end
