# encoding: utf-8
class Survey::Piece::Form < Cms::Piece
  default_scope where(model: 'Survey::Form')

  def target_form
    content.public_forms.find_by_id(setting_value(:target_form_id))
  end

  def head_css
    setting_value(:head_css).to_s
  end

  def upper_text
    setting_value(:upper_text).to_s
  end

  def lower_text
    setting_value(:lower_text).to_s
  end
end
