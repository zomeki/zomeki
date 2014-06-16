# encoding: utf-8
module Sys::Lib::File::Transfer
  require "rsync"

  def transfer_files(options={})
    load_transfer_settings

    _logging = options[:logging] || true
    _sites   = options[:sites] || Cms::Site.where(:state => 'public').order(:id)
    _version = Time.now.to_i

    _sites.each do |site|
      site = Cms::Site.find_by_id(site) if site.is_a?(Integer)
      _settings = get_transfer_site_settings site
      next if _settings.size <= 0

      dest_addr = _settings[:dest_dir]
      dest = if _settings[:dest_user].to_s != '' && _settings[:dest_host].to_s != ''
        dest_addr = "#{_settings[:dest_user]}@#{_settings[:dest_host]}:#{_settings[:dest_dir]}"
        @opt_remote_shell ? "-e \"#{@opt_remote_shell}\" #{dest_addr}" : dest_addr;
      else
        dest_addr
      end

      _rsync = lambda do |src, dest, command_opts|
        rsync(src, dest, command_opts) do |res|
          if _logging && res.success?
            parent_dir = src.gsub(/#{Rails.root}/, '.')
            res.changes.each do |change|
              update_type = change.update_type
              file_type   = change.file_type
              next if update_type == :no_update
              operation = if ([:sent, :recv].include?(update_type) && change.timestamp == :new) ||
                (file_type == :directory && update_type == :change)
                :create
              elsif update_type == :message && change.summary == 'deleting'
                :delete
              elsif [change.checksum, change.size, change.timestamp].include?(:changed)
                :update
              end
              # save
              Sys::TransferredFile.new({
                :site_id     => site.id,
                :version     => _version,
                :operation   => operation,
                :file_type   => file_type,
                :parent_dir  => parent_dir,
                :path        => change.filename,
                :destination => dest_addr,
              }).save
            end
          end
        end
      end

      # sync common dir
      options = []
      options << "--include-from=#{Rails.root}/#{@opt_include}" if @opt_include
      options << @opts if @opts
      _rsync.call("#{Rails.root}/public/", dest, options)

      # sync site dir
      options = []
      options << "--exclude-from=#{Rails.root}/#{@opt_exclude}" if @opt_exclude
      options << @opts if @opts
      _rsync.call("#{site.public_path}/", dest, options)
    end
  end

protected
  def load_transfer_settings
    @opts             = Zomeki.config.application['sys.transfer_opts']
    @opt_exclude      = Zomeki.config.application['sys.transfer_opt_exclude']
    @opt_include      = Zomeki.config.application['sys.transfer_opt_include']
    @opt_remote_shell = Zomeki.config.application['sys.transfer_opt_remote_shell']
  end

  def get_transfer_site_settings(site)
    _settings = {}
    _settings[:dest_user]  = site.setting_transfer_dest_user
    _settings[:dest_host]  = site.setting_transfer_dest_host
    _settings[:dest_dir]   = site.setting_transfer_dest_dir
    _settings.reject!{|key, value| value.blank? }
    return {} unless _settings[:dest_dir]
    _settings
  end

  def rsync(src, dest, options=[], &block)
    res = Rsync.run(src, dest, options)
    yield(res) if block_given?
    res
  end
end
