class Sys::OperationLog < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order('updated_at DESC')

  belongs_to :loggable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'

  validates :loggable, :presence => true
  validates :user, :presence => true
end
