class Organization::Piece::ContactInformation < Cms::Piece
  default_scope { where(model: 'Organization::ContactInformation') }
end
