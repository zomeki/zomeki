# encoding: utf-8
class Survey::Piece::Form < Cms::Piece
  default_scope where(model: 'Survey::Form')

  def target_form
    content.public_forms.find_by_id(setting_value(:target_form_id))
  end
end
