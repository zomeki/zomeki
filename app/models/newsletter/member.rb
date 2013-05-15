# encoding: utf-8
class Newsletter::Member < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Letter

  belongs_to :status, :foreign_key => :state, :class_name => 'Sys::Base::Status'

  validates_presence_of :letter_type, :email

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_email'
        self.and_keywords v, :email
      when 's_letter_type'
        self.and "#{self.class.table_name}.letter_type", v
      when 's_state'
        self.and "#{self.class.table_name}.state", v
      end
    end if params.size != 0

    return self
  end

end