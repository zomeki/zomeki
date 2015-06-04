class GpArticle::Piece::Archive < Cms::Piece
  NUM_DOCS_VISIBILITY_OPTIONS = [['表示する', 'visible'], ['表示しない', 'hidden']]
  TERM_OPTIONS = [['月別', 'month'], ['年・月別', 'year_month'], ['年別', 'year']]

  default_scope where(model: 'GpArticle::Archive')

  def num_docs_visibility
    setting_value(:num_docs_visibility).to_s
  end

  def num_docs_visibility_text
    NUM_DOCS_VISIBILITY_OPTIONS.detect{|o| o.last == num_docs_visibility }.try(:first).to_s
  end

  def num_docs_visible?
    num_docs_visibility != 'hidden'
  end

  def term
    setting_value(:term).to_s
  end

  def term_text
    TERM_OPTIONS.detect{|o| o.last == term }.try(:first).to_s
  end
end
