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
            item.save
          rescue
          end
        end
      end
    end
  end

  def parse_date(datestring, format='%m月%d日')
    begin
      return Date.strptime(datestring, format)
    rescue
      return nil
    end
  end

end
