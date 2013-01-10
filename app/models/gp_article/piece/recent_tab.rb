# encoding: utf-8
class GpArticle::Piece::RecentTab < Cms::Piece
  default_scope where(model: 'GpArticle::RecentTab')

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['list_count']).present?
      errors.add(:base, "#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end
end
