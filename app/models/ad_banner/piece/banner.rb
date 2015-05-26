# encoding: utf-8
class AdBanner::Piece::Banner < Cms::Piece
  SORT_OPTIONS = [['表示順', 'ordered'], ['ランダム', 'random']]
  IMPL_OPTIONS = [['動的', 'dynamic'], ['静的', 'static']]

  default_scope where(model: 'AdBanner::Banner')

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    errors.add(:base, "#{self.class.human_attribute_name :sort} #{errors.generate_message :base, :blank}") unless sort
    errors.add(:base, "#{self.class.human_attribute_name :impl} #{errors.generate_message :base, :blank}") unless impl
  end

  def content
    AdBanner::Content::Banner.find(super)
  end

  def groups
    content.groups
  end

  def groups_for_option
    content.groups_for_option
  end

  def group
    groups.find_by_id(setting_value(:group_id))
  end

  def banners
    content.banners
  end

  def banner_node
    content.banner_node
  end

  def sort
    SORT_OPTIONS.detect{|so| so.last == (in_settings[:sort] || setting_value(:sort)) }
  end

  def sort_text
    sort.try(:first).to_s
  end

  def impl
    IMPL_OPTIONS.detect{|io| io.last == (in_settings[:impl] || setting_value(:impl)) }
  end

  def impl_text
    impl.try(:first).to_s
  end

  def upper_text
    setting_value(:upper_text).to_s
  end

  def lower_text
    setting_value(:lower_text).to_s
  end

  private

  def set_default_settings
    settings = self.in_settings
    settings[:sort] = SORT_OPTIONS.first.last if setting_value(:sort).blank?
    settings[:impl] = IMPL_OPTIONS.first.last if setting_value(:impl).blank?
    self.in_settings = settings
  end
end
