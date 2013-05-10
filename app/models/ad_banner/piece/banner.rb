# encoding: utf-8
class AdBanner::Piece::Banner < Cms::Piece
  SORT_OPTIONS = [['表示順', 'ordered'], ['ランダム', 'random']]

  default_scope where(model: 'AdBanner::Banner')

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    errors.add(:base, "#{self.class.human_attribute_name :sort} #{errors.generate_message(:base, :blank)}") if in_settings['sort'].blank?
  end

  def content
    AdBanner::Content::Banner.find(super)
  end

  def groups
    content.groups
  end

  def groups_for_option
    groups.map {|g| [g.title, g.id] }
  end

  private

  def set_default_settings
    settings = self.in_settings
    settings['sort'] = SORT_OPTIONS.first.last if setting_value(:sort).blank?
    self.in_settings = settings
  end
end
