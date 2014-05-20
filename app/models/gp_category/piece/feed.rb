# encoding: utf-8
class GpCategory::Piece::Feed < Cms::Piece
  validate :validate_settings

  def filename
    setting_value(:filename).to_s
  end

  def validate_settings
    if !in_settings['filename'].blank?
      errors.add(:filename, :not_a_filename) if in_settings['filename'] !~ /^[0-9A-Za-z@\-_\+\s]+$/
      errors.add(:filename, :exclusion) if in_settings['filename'] == 'index'
    end
  end

  def public_feed_uri(format = 'rss')
    name = filename.presence || 'feed'
    "#{name}.#{format}"
  end
end
