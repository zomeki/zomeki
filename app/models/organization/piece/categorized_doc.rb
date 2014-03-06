class Organization::Piece::CategorizedDoc < Cms::Piece
  default_scope where(model: 'Organization::CategorizedDoc')

  after_initialize :set_default_settings

  store :etcetera, accessors: [:category_ids]

  def category_ids=(ids)
    etcetera[:category_ids] = ids.to_a
  end

  def category_ids
    etcetera[:category_ids].to_a
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end

  private

  def set_default_settings
    settings = self.in_settings

#    settings[:foo] = 'bar' if setting_value(:foo).nil?

    self.in_settings = settings
  end
end
