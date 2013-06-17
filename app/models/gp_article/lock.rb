# encoding: utf-8
class GpArticle::Lock < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :lockable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'
end
