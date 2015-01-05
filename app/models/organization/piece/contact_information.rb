class Organization::Piece::ContactInformation < Cms::Piece
  SOURCE_OPTIONS = [['組織コンテンツ', 'organization_group'], ['グループ', 'sys_group']]

  default_scope { where(model: 'Organization::ContactInformation') }

  def source
    setting_value(:source) || SOURCE_OPTIONS.first.last
  end

  def source_text
    SOURCE_OPTIONS.detect{|o| o.last == source }.try(:first).to_s
  end
end
