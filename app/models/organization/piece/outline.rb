class Organization::Piece::Outline < Cms::Piece
  default_scope { where(model: 'Organization::Outline') }
end
