# encoding: utf-8
class Cms::PieceSetting < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :piece, :foreign_key => :piece_id, :class_name => 'Cms::Piece'

  validates_presence_of :piece_id, :name

  def extra_values=(ev)
    self.extra_value = YAML.dump(ev) if ev.is_a?(Hash)
    return ev
  end

  def extra_values
    return {}.with_indifferent_access unless self.extra_value.is_a?(String)
    ev = YAML.load(self.extra_value)
    return {}.with_indifferent_access unless ev.is_a?(Hash)
    return ev.with_indifferent_access
  end
end
