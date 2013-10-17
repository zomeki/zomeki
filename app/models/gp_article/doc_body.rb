class GpArticle::DocBody < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order("#{self.table_name}.updated_at DESC, #{self.table_name}.created_at DESC")

  belongs_to :doc
end
