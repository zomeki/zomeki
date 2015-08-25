class GpCategory::Template < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  attr_accessible :name, :title, :body

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCategory::Content::CategoryType'
  validates_presence_of :content_id

  validates :name, :presence => true, :uniqueness => {:scope => :content_id}
  validates :title, :presence => true

  def containing_modules
    body.scan(/\[\[module\/([\w-]+)\]\]/).map{|m| content.template_modules.find_by_name(m.first) }.compact
  end
end
