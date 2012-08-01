# encoding: utf-8
class PortalGroup::Piece::RecentDoc < Cms::Piece
  validate :validate_settings
  
  def list_types
    [['展開形式','opened'],['一行形式','list']]
  end
  
  def setting_label(name)
    value = setting_value(name)
    case name
    when :list_type
      list_types.each {|c| return c[0] if c[1].to_s == value.to_s}
    end
    value
  end
  
  def validate_settings
    if !in_settings['list_count'].blank?
      errors.add(:list_count, :not_a_number) if in_settings['list_count'] !~ /^[0-9]+$/
    end
  end
end