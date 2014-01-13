class GpArticle::Piece::Comment < Cms::Piece
  AUTHORS_VISIBILITY_OPTIONS = [['表示する', 'visible'], ['表示しない', 'hidden']]

  default_scope where(model: 'GpArticle::Comment')

  validate :validate_settings

  def validate_settings
    if (dn = in_settings['docs_number']).present?
      errors.add(:base, "#{self.class.human_attribute_name :docs_number} #{errors.generate_message(:base, :not_a_number)}") unless dn =~ /^[0-9]+$/
    end
  end

  def docs_number
    (setting_value(:docs_number).presence || 1000).to_i
  end

  def authors_visibility
    setting_value(:authors_visibility).to_s
  end

  def authors_visibility_text
    AUTHORS_VISIBILITY_OPTIONS.detect{|o| o.last == setting_value(:authors_visibility) }.try(:first).to_s
  end

  def authors_visible?
    setting_value(:authors_visibility) != 'hidden'
  end
end
