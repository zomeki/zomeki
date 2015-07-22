# encoding: utf-8
class GpArticle::Piece::Doc < Cms::Piece
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'], ['ランダム', 'random']]
  IMPL_OPTIONS = [['動的', 'dynamic'], ['静的', 'static']]

  default_scope where(model: 'GpArticle::Doc')

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['docs_number']).present?
      errors.add(:base, "#{self.class.human_attribute_name :docs_number} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def docs_number
    (setting_value(:docs_number).presence || 1000).to_i
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def more_link_body
    setting_value(:more_link_body).to_s
  end

  def more_link_url
    setting_value(:more_link_url).to_s
  end

  def impl
    IMPL_OPTIONS.detect{|io| io.last == (in_settings[:impl] || setting_value(:impl)) }
  end

  def impl_text
    impl.try(:first).to_s
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    settings['docs_order'] = DOCS_ORDER_OPTIONS.first.last if setting_value(:docs_order).nil?
    settings['impl'] = IMPL_OPTIONS.first.last if setting_value(:impl).blank?

    self.in_settings = settings
  end
end
