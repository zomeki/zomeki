# encoding: utf-8
class PublicBbs::Category < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Tree
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Content

  belongs_to :content, :foreign_key => :content_id, :class_name => 'PublicBbs::Content::Thread'
  belongs_to :layout,  :foreign_key => :layout_id,  :class_name => 'Cms::Layout'
  belongs_to :parent,  :foreign_key => :parent_id,  :class_name => self.name
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'

  validates :parent_id, :presence => true
  validates :state,     :presence => true
  validates :name,      :presence => true, :uniqueness => { :scope => :content_id }
  validates :title,     :presence => true

  def self.root_items(conditions = {})
    conditions = conditions.merge({:parent_id => 0, :level_no => 1})
    self.find(:all, :conditions => conditions, :order => :sort_no)
  end

  def public_children
    item = self.class.new.public
    item.and :content_id, content_id
    item.and :parent_id, id
    item.find(:all, :order => :sort_no)
  end

  def public_descendants
    public_children.inject([]) do |cats, pc|
      cats << pc.id
      cats.concat(pc.public_descendants)
    end
  end

  def public_uri
    full_name = parents_tree.inject([]){|names, c| names << c.name }.join('/')
    "#{content.category_node.public_uri}#{full_name}/"
  end
end
