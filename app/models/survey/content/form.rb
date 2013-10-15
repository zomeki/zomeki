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

  def public_node
    public_nodes.first
  end

  def mail_from
    setting_value(:mail_from).to_s
  end

  def mail_to
    setting_value(:mail_to).to_s
  end
end
