# encoding: utf-8
module PortalCalendar::FormHelper
  def portal_calendar_checkbox_tag_form(disp_name, collection, group_name, name, prop, checked, select_all=true)
		content_tag(:p) do
			concat content_tag(:h3){ disp_name }

			if select_all
				#全選択オプションの追加
				concat content_tag(:input, '', {:type => 'checkbox', :name => sprintf("%s[%s]",group_name, 0), :value => true, :checked => checked.index(0) ? true : false})
				concat content_tag(:label, '全選択')
				concat '  '
			end
				
			collection.each do |item|
				concat content_tag(:input, '', {:type => 'checkbox', :name => sprintf("%s[%s]",group_name, item.attributes[name]), :value => true, :checked => checked.index(item.attributes['id']) ? true : false})
				concat content_tag(:label, item.attributes[prop])
				concat '  '
			end
		end
  end
end
