# encoding: utf-8
def dump(data)
  Sys::Lib::Debugger::Dump.dump_log(data)
end

def error_log(message)
  Rails.logger.error "[ USER ERROR #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} ]: #{message}"
end
