class Approval::Assignment < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :approval
  belongs_to :user, :class_name => 'Sys::User'

  validates_presence_of :approval_id, :user_id
end
