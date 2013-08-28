# encoding: utf-8
class Rank::Piece::Rank < Cms::Piece
  default_scope where(model: 'Rank::Rank')

  def content
    Rank::Content::Rank.find(super)
  end

  def ranking_targets
  	return [['PV', 'pageviews'], ['訪問者数', 'visitors']]
  end

  def ranking_terms
  	return [['前日', 'previous_days'], ['先週（月曜日〜日曜日）', 'last_weeks'], ['先月', 'last_months'], ['週間（前日から一週間）', 'this_weeks']]
  end

  def show_label(key, values)
    val = setting_value(key)
    values.each do |t|
      return t[0] if t[1].to_s == val
    end
    nil
  end

  def ranks
  end
end
