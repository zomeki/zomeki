# encoding: utf-8
class GpTemplate::Content::Template < Cms::Content
  default_scope { where(model: 'GpTemplate::Template') }

  has_many :templates, :foreign_key => :content_id, :class_name => 'GpTemplate::Template', :dependent => :destroy
end
