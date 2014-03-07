class Organization::Piece::AllGroup < Cms::Piece
  default_scope { where(model: 'Organization::AllGroup') }
end
