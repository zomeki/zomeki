class Sys::Lib::Logger::Date < Sys::Lib::Logger::Base
  def log_file(name)
    "#{Rails.root}/log/" + @time.strftime('%Y/%m/%d/') + "#{name}.log"
  end
end