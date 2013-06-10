# encoding: utf-8
def dump(data)
  Sys::Lib::Debugger::Dump.dump_log(data)
end

def info_log(message)
  Rails.logger.info "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] INFO  #{message}"
end

def warn_log(message)
  Rails.logger.warn "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] WARN  #{message}"
end

def error_log(message)
  Rails.logger.error "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] ERROR  #{message}"
end
