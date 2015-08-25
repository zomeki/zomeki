# encoding: utf-8
class Cms::Piece::PickupDocXml < Cms::Model::Base::PieceExtension
  CONDITION_OPTIONS = [['すべてを含む', 'and'], ['いずれかを含む', 'or']]
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]

  set_model_name 'cms/piece/pickup_doc'
  set_column_name :xml_properties
  set_node_xpath 'docs/doc'
  set_primary_key :name

  attr_accessor :name
  attr_accessor :content_id
  attr_accessor :doc_id
  attr_accessor :doc_name
  attr_accessor :sort_no

  validates_presence_of :content_id, :doc_id, :sort_no

  def doc
    GpArticle::Doc.find_by_content_id_and_name_and_state(content_id, doc_name, 'public')
  end
  
end
