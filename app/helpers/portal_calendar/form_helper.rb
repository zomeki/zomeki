# encoding: utf-8
module PortalCalendar::FormHelper
  def portal_calendar_checkbox_tag_form(collection, group_name, name, prop, checked)
		content_tag(:p) do
			concat content_tag(:h4){ group_name }
			collection.each do |item|
				concat content_tag(:input, '', {:type => 'checkbox', :name => sprintf("%s[%s]",group_name, item.attributes[name]), :value => true, :checked => checked.index(item.attributes['id']) ? true : false})
				concat content_tag(:label, item.attributes[prop])
			end
		end
  end
end
