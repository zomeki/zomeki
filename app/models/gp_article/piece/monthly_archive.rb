class GpArticle::Piece::MonthlyArchive < Cms::Piece
  NUM_DOCS_VISIBILITY_OPTIONS = [['表示する', 'visible'], ['表示しない', 'hidden']]

  default_scope where(model: 'GpArticle::MonthlyArchive')

  def num_docs_visibility
    setting_value(:num_docs_visibility).to_s
  end

  def num_docs_visibility_text
    NUM_DOCS_VISIBILITY_OPTIONS.detect{|o| o.last == setting_value(:num_docs_visibility) }.try(:first).to_s
  end

  def num_docs_visible?
    setting_value(:num_docs_visibility) != 'hidden'
  end
end
