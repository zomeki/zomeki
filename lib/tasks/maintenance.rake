namespace :zomeki do
  namespace :maintenance do
    desc 'Replace @title@ to @title_link@ in settings'
    task(:replace_title_with_title_link => :environment) do
      ccs = Cms::ContentSetting.arel_table
      Cms::ContentSetting.where(ccs[:value].matches('%@title@%')).each do |cs|
        cs.update_column(:value, cs.value.gsub('@title@', '@title_link@'))
      end
    end
  end
end
