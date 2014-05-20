# encoding: utf-8
module GpCalendar::Controller::Holiday

  def create_default_holidays(content)
    if content.holidays.length == 0
      file = "#{Rails.root}/config/holiday.yml"
      if File.exist?(file)
        yaml = YAML.load_file(file)
        yaml.each do |val|
          begin
            item = content.holidays.build(val)
            item.date ||= parse_date(val["date"]) rescue item.date = parse_date(val["date"], '%m-%d')
            if item.date.blank?
              begin
                /(\d+)月の第(\d+)(\W+)曜日/ =~ val["date"]
                item.date = specific_date($1, $2, $3)
              rescue
              end
            end
            item.save
          rescue
          end
        end
      end
    end
  end

  def specific_date(month, times, wday, year = Time.now.year)
    d = Date.new(year, month.to_i, 1)
    i = ["日", "月", "火", "水", "木", "金", "土"].index(wday)
    d = d + (d.wday > i ? (7 + i - d.wday).days : (i - d.wday).abs.days)
    d = d + (7 * (times.to_i - 1)).days
    return d
  end

  def parse_date(datestring, format='%m月%d日')
    begin
      return Date.strptime(datestring, format)
    rescue
      return nil
    end
  end

end
