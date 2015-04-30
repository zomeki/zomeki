namespace :zomeki do
  namespace :gp_calendar do
    desc 'Publish todays events'
    task(:publish_todays_events => :environment) do
      Cms::Node.public.where(model: 'GpCalendar::TodaysEvent').each do |node|
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}")
      end
    end
  end
end
