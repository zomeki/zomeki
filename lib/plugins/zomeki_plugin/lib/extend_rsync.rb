# encoding: utf-8
module Rsync
  class Change
    def file_type
      t = case raw_file_type
        when 'f'
          :file
        when 'd'
          :directory
        when 'L'
          :symlink
        when 'D'
          :device
        when 'S'
          :special
      end
      # custom
      return t unless t == :directory
      return t if filename.to_s[-1] == '/'
      return :file if update_type == :message && message == 'deleting'
      t
    end
  end

  class Result
    def status_code
      @exitcode
    end

    def status
      {:success => success?, :code => @exitcode, :message => error }
    end
  end
end
