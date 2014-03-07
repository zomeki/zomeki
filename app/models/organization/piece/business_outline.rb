class Organization::Piece::BusinessOutline < Cms::Piece
  default_scope { where(model: 'Organization::BusinessOutline') }
end
