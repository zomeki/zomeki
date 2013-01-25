# encoding: utf-8
class PortalCalendar::Genre < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Content
  
  belongs_to :status,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :content,  :foreign_key => :content_id, :class_name => 'Cms::Content'
  
  validates_presence_of :state, :title
  validates_uniqueness_of :title, :scope => [:content_id]
  
  def self.root_items(conditions = {})
    conditions = conditions.merge({})
    self.find(:all, :conditions => conditions, :order => :sort_no)
  end
  
  def public_path
    "#{content.public_path}/genres/#{name}/index.html"
  end
  
  def node_label(options = {})
    title
  end
  
  def bread_crumbs(node)
    crumbs = []
    node.routes.each do |r|
      c = []
      r.each {|i| c << [i.title, i.public_uri] }
      
      uri = c.last[1] || '/'
      c << [title, "#{uri}#{name}/"]
      
      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
