# encoding: utf-8
module PortalCalendar::FormHelper
	def get_genre_title(item)
		title = item.get_genre_title(true)
		return title.size > 0 ? content_tag(:span, title, :class=>sprintf("genre%02d", item.id)) : "&nbsp;".html_safe
	end
	
	def get_status_title(item)
		title = item.get_status_title(true)
		return title.size > 0 ? content_tag(:span, title, :class=>sprintf("status%02d", item.id)) : "&nbsp;".html_safe
	end
	
  def monthly_event_tag(item)
		content_tag(:table,
			content_tag(:tr) do
				content_tag(:td, item.get_genre_title)
				content_tag(:td, content_tag(:li, link_to_if(item.event_uri.present?, item.title, item.event_uri, :target => "_blank"), :class=>'event'))
			end
			)
	end

	def portal_calendar_link_tag_form(url, collection, select_all=true)
		
		#ステータスは全て
		param_estt = "estt=0"
		content_tag(:ul) do
			if select_all
				#全選択オプションの追加
				concat content_tag(:li, link_to('全選択', url+"?egnr=0&#{param_estt}"), :class=>'genre01')
			end

			idx = 2
			collection.each do |item|
				concat content_tag(:li, link_to(item.attributes['title'], url+"?egnr=#{item.attributes['id']}&#{param_estt}"), :class=>sprintf("genre%02d", idx))
				idx = idx + 1
			end
		end
	end
end
