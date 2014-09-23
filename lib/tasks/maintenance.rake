namespace :zomeki do
  namespace :maintenance do
    desc 'Replace @title@ to @title_link@ in settings'
    task(:replace_title_with_title_link => :environment) do
      ccs = Cms::ContentSetting.arel_table
      Cms::ContentSetting.where(ccs[:value].matches('%@title@%')).each do |cs|
        info_log "#{cs.content.class.name}(#{cs.content_id}):#{cs.content.name}"
        cs.update_column(:value, cs.value.gsub('@title@', '@title_link@'))
      end

      cps = Cms::PieceSetting.arel_table
      Cms::PieceSetting.where(cps[:value].matches('%@title@%')).each do |ps|
        info_log "#{ps.piece.class.name}(#{ps.piece_id}):#{ps.piece.title}(#{ps.piece.name})"
        ps.update_column(:value, ps.value.gsub('@title@', '@title_link@'))
      end
    end
  end
end
