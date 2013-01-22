class Gnav::MenuItem < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Auth::Content
  include Cms::Model::Base::Page

  default_scope order(:sort_no)

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Gnav::Content::MenuItem'
  validates_presence_of :content_id

  # Page
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'

  # Proper
  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  has_many :category_sets

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  def public_uri=(uri)
    @public_uri = uri
  end

  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.menu_item_node
    @public_uri = "#{node.public_uri}#{name}/"
  end

  def public_full_uri=(uri)
    @public_full_uri = uri
  end

  def public_full_uri
    return @public_full_uri if @public_full_uri
    return nil unless node = content.menu_item_node
    @public_full_uri = "#{node.public_full_uri}#{name}/"
  end

  def categories
    category_sets.inject([]) {|result, category_set|
      if category_set.layer == 'descendants'
        result | category_set.category.descendants
      else
        result | [category_set.category]
      end
    }
  end
end
