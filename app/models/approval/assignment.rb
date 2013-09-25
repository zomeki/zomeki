class Approval::Assignment < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :assignable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'

  validates_presence_of :assignable_type, :assignable_id, :user_id
end
