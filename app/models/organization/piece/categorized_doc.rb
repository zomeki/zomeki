class Organization::Piece::CategorizedDoc < Cms::Piece
  default_scope where(model: 'Organization::CategorizedDoc')

  after_initialize :set_default_settings

  private

  def set_default_settings
    settings = self.in_settings

#    settings[:foo] = 'bar' if setting_value(:foo).nil?

    self.in_settings = settings
  end
end
