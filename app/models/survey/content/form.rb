# encoding: utf-8
class Survey::Content::Form < Cms::Content
  default_scope where(model: 'Survey::Form')

  has_many :forms, :foreign_key => :content_id, :class_name => 'Survey::Form', :dependent => :destroy

  def public_forms
    forms.public
  end

  def public_nodes
    nodes.public
  end
end
