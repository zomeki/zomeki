# encoding: utf-8
module PortalCalendar::FormHelper
  def portal_calendar_link_tag_form(url, collection, select_all=true)
		
		#ステータスは全て
		param_estt = "estt=0"
		content_tag(:ul) do
			if select_all
				#全選択オプションの追加
				concat content_tag(:li, link_to('全選択', url+"?egnr=0&#{param_estt}"))
			end

			collection.each do |item|
				concat content_tag(:li, link_to(item.attributes['title'], url+"?egnr=#{item.attributes['id']}&#{param_estt}"))
			end
		end
	end
end
