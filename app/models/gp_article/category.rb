class GpArticle::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpArticle::Content::Doc'

  validates :concept_id, :presence => true
  validates :content_id, :presence => true

  belongs_to :category_type, :foreign_key => :category_type_id, :class_name => 'GpArticle::CategoryType'

  belongs_to :parent, :foreign_key => :parent_id, :class_name => self.name
  has_many :children, :foreign_key => :parent_id, :class_name => self.name,
                      :order => :sort_no, :dependent => :destroy

  belongs_to :layout, :foreign_key => :layout_id, :class_name => 'Cms::Layout'

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_and_belongs_to_many :docs, :class_name => 'GpArticle::Doc', :join_table => 'gp_article_categories_gp_article_docs'

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  default_scope order(:category_type_id, :level_no, :sort_no)

  def descendants(categories=[])
    categories << ["#{'-' * level_no} #{parent.try(:title)}:#{title}", id]

    unless children.empty?
      children.map {|c| c.descendants(categories) }
    end

    return categories
  end

#TODO: ツリー表示は不採用ここから
if false
  def descendants(selected_ids=[])
    tree = {key: id, title: title, tooltip: name}

    if children.empty?
      tree[:select] = selected_ids.include?(id)
    else
      tree[:expand] = true
      tree[:children] = children.map {|c| c.descendants(selected_ids) }
      tree[:select] = tree[:children].all? {|c| c[:select] }
    end

    return tree
  end
end
#TODO: ツリー表示は不採用ここまで
end
