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

  def show_counts
    return [['表示する', 1], ['表示しない', 0]]
  end

  def show_label(key, values)
    val = setting_value(key)
    values.each do |t|
      return t[0] if t[1].to_s == val
    end
    nil
  end

  def ranking_target
    setting_value(:ranking_target).to_s
  end

  def ranking_term
    setting_value(:ranking_term).to_s
  end

  def display_count
    setting_value(:display_count).to_i == 0 ? 50 : setting_value(:display_count).to_i
  end

  def show_count
    setting_value(:show_count).to_i
  end

  def more_link_body
    setting_value(:more_link_body).to_s
  end

  def more_link_url
    setting_value(:more_link_url).to_s
  end

  def ranks
  end
end
