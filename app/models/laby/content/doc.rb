# encoding: utf-8
class Laby::Content::Doc < Cms::Content
  def doc_node
    return @doc_node if @doc_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Laby::Doc'
    @doc_node = item.find(:first, :order => :id)
  end
end