# encoding: utf-8
class Newsletter::Doc < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Delivery

  belongs_to :status,           :foreign_key => :state,           :class_name => 'Sys::Base::Status'
  belongs_to :content,          :foreign_key => :content_id,      :class_name => 'Newsletter::Content::Base'
  has_many   :logs,             :foreign_key => :doc_id,          :class_name => 'Newsletter::DeliveryLog',
                                :order => :updated_at, :dependent => :destroy

  validates_presence_of :state, :title, :body

  def validate
    if content.template_state == 'enabled'
      errors.add :body, "がテンプレートの内容から変更されていません。" if body == content.template
      errors.add :mobile_body, "がテンプレートの内容から変更されていません。" if mobile_body == content.template_mobile
    end
  end

  def tests
    return @tests if @tests
    test = Newsletter::Test.new.enabled
    test.and :content_id, self.content_id
    test.order 'agent_state DESC, id DESC'
    @tests = test.find(:all)
  end

  def members
    return @members if @members
    member = Newsletter::Member.new.enabled
    member.and :content_id, self.content_id
    member.order 'letter_type DESC, id'
    @members = member.find(:all)
  end

  def mail_title(is_mobile=false, options={})
    _title = ""
    if is_mobile
      _title = mobile_title.blank? ? title : mobile_title
    else
      _title = title
    end
    _title
  end

  def mail_body(is_mobile=false, options={})
    _body = ""
    if is_mobile
      _body = mobile_body.blank? ? body : mobile_body
      _body += "\n\n" + content.signature_mobile if content.signature_state == 'enabled'
    else
      _body = body
      _body += "\n\n" + content.signature if content.signature_state == 'enabled'
    end
    _body
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_title'
        self.and_keywords v, :title
      end
    end if params.size != 0

    return self
  end

end