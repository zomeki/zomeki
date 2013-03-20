# encoding: utf-8
module Cms::Model::Rel::Content
  def self.included(mod)
    mod.belongs_to :content,  :foreign_key => :content_id, :class_name => 'Cms::Content'
  end
  
  def concept(reload = nil)
    content.concept(reload)
  end
  
  def content_name
    content ? content.name : Cms::Lib::Modules.module_name(:cms)
  end
end