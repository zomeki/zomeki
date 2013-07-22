class GpCategory::Categorization < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :categorizable, polymorphic: true
  belongs_to :category
end
