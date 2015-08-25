# encoding: utf-8
class Cms::Piece::PickupDoc < Cms::Piece
  default_scope where(model: 'Cms::PickupDoc')

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['list_count']).present?
      errors.add(:base, "#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def list_count
    (setting_value(:list_count).presence || 10).to_i
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  private

  def set_default_settings
    settings = self.in_settings
    settings[:list_count] = 10 if setting_value(:list_count).nil?
    settings[:list_style] = '@title_link@(@publish_date@ @group@)' if setting_value(:list_style).nil?
    settings[:date_style] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    self.in_settings = settings
  end
end
