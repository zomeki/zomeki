# encoding: utf-8
class Newsletter::DeliveryLog < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Delivery
  include Newsletter::Model::Base::Letter

  belongs_to :status,         :foreign_key => :state,           :class_name => 'Sys::Base::Status'
  belongs_to :content,        :foreign_key => :content_id,      :class_name => 'Newsletter::Content::Base'

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_email'
        self.and_keywords v, :email
      end
    end if params.size != 0

    return self
  end
end