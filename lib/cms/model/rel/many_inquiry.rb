# encoding: utf-8
module Cms::Model::Rel::ManyInquiry

  def self.included(mod)
    mod.has_many :inquiries, :foreign_key => 'parent_unid', :primary_key => 'unid', :class_name => 'Cms::Inquiry',
      :dependent => :destroy
    mod.accepts_nested_attributes_for :inquiries, :allow_destroy => true

    mod.after_save :save_inquiry_parent_unid
  end

  def inquiry_states
    [['表示','visible'],['非表示','hidden']]
  end

  def build_default_inquiry(params = {})
    if inquiries.size == 0
      if g =  Core.user.group
        inquiries.build({:state => default_inquiry_state, :group_id => g.id, :tel => g.tel, :fax => g.fax, :email => g.email}.merge(params))
      else
        inquiries.build(params)
      end
    end
  end

  def validate_inquiry
    return true if content && !content.inquiry_related?

    inquiries.each_with_index do |inquiry, i|
      next unless inquiry.visible?

      inquiry.errors.add(:tel, :onebyte_characters) if inquiry.tel.to_s !~/^[ -~｡-ﾟ]*$/
      inquiry.errors.add(:fax, :onebyte_characters) if inquiry.fax.to_s !~/^[ -~｡-ﾟ]*$/
      inquiry.errors.add(:email, :invalid) if inquiry.email.to_s !~/^[ -~｡-ﾟ]*$/
    end

    inquiries.each do |inquiry|
      inquiry.errors.each do |key|
        errors.add(:"inquiries/#{key}", inquiry.errors[key]) unless errors.include?(:"inquiries/#{key}")
      end
    end
  end

  def save_inquiry_parent_unid
    inquiries.each do |inquiry|
      inquiry.update_attribute(:parent_unid, unid) if inquiry.parent_unid.blank?
      inquiry.destroy if inquiry.group_id.blank?
    end
  end

  def default_inquiry_state
    if content && content.inquiry_extra_values
      content.inquiry_extra_values[:state]
    else
      'hidden'
    end
  end

  def inquiry_display_fields
    if content && content.inquiry_extra_values
      content.inquiry_extra_values[:display_fields]
    else
      ['group_id', 'charge', 'address', 'tel', 'fax', 'email', 'note']
    end
  end

  def inquiry_display_field?(name)
    inquiry_display_fields.include?(name.to_s)
  end
end
