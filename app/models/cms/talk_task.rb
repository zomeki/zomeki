# encoding: utf-8
class Cms::TalkTask < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :path
end
