# encoding: utf-8
class Gnav::CategorySet < ActiveRecord::Base
  include Sys::Model::Base

  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]

  belongs_to :menu_item
  belongs_to :category, :class_name => 'GpCategory::Category'

  after_initialize :set_defaults

  def layer_text
    LAYER_OPTIONS.detect{|lo| lo.last == layer }.try(:first)
  end

  private

  def set_defaults
    self.layer ||= LAYER_OPTIONS.first.last if self.has_attribute?(:layer)
  end
end
