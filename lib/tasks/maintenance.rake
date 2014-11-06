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

      gctm = GpCategory::TemplateModule.arel_table
      GpCategory::TemplateModule.where(gctm[:doc_style].matches('%@title@%')).each do |tm|
        info_log "#{tm.class.name}(#{tm.id}):#{tm.title}(#{tm.name})"
        tm.update_column(:doc_style, tm.doc_style.gsub('@title@', '@title_link@'))
      end
    end

    desc 'Clean invalid links'
    task(:clean_invalid_links => :environment) do
      count = 0
      GpArticle::Link.find_each do |l|
        next if l.doc && l.doc.state_public?
        l.destroy
        count += 1
      end
      puts count > 0 ? "#{count} invalid links removed." : 'No invalid links.'
    end
  end
end
