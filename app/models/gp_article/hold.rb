# encoding: utf-8
class GpArticle::Hold < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :holdable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'
end
