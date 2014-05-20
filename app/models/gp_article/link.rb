class GpArticle::Link < ActiveRecord::Base
  include Sys::Model::Base

  validates_presence_of :doc_id, :url

  belongs_to :doc
end
