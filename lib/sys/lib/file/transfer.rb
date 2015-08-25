# encoding: utf-8
module Sys::Lib::File::Transfer
  require "rsync"

  def transfer_files(options={})
    load_transfer_settings

    # options
    _logging = options[:logging] || true
    _trial   = options.has_key?(:trial) ? options[:trial] : false;
    _user_id = options[:user] || Core.user.id rescue nil;
    _sites   = options[:sites] || Cms::Site.where(:state => 'public').order(:id)
    _files   = options[:files]
    _version = options[:version] || Time.now.to_i

    result = {:version => _version, :sites => {} }

    _sites.each do |site|
      site = Cms::Site.find_by_id(site) if site.is_a?(Integer)
      _settings = get_transfer_site_settings site
      next if _settings.size <= 0

      result[:sites][site.id] = []

      dest_addr = _settings[:dest_dir]
      dest = if _settings[:dest_user].to_s != '' && _settings[:dest_host].to_s != ''
        dest_addr = "#{_settings[:dest_user]}@#{_settings[:dest_host]}:#{_settings[:dest_dir]}"
        @opt_remote_shell ? "-e \"#{@opt_remote_shell}\" #{dest_addr}" : dest_addr;
      else
        dest_addr
      end

      _ready_options = lambda do |include_file, file_base|
        options = []
        options << "-n" if _trial
        if include_file
          options << "--include-from=#{include_file.path}"
        else
          if file_base =='common' && @opt_include
            options << "--include-from=#{Rails.root}/#{@opt_include}"
          end
          if file_base =='site' && @opt_exclude
            options << "--exclude-from=#{Rails.root}/#{@opt_exclude}"
          end
        end
        options << @opts if @opts
        return options
      end

      _rsync = lambda do |src, dest, command_opts|
        rsync(src, dest, command_opts) do |res|
          return res unless _logging

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
            attrs = {
              :site_id     => site.id,
              :user_id     => _user_id,
              :version     => _version,
              :operation   => operation,
              :file_type   => file_type,
              :parent_dir  => parent_dir,
              :path        => change.filename,
              :destination => dest_addr,
            }
            model = _trial ? Sys::TransferableFile : Sys::TransferredFile;
            model = model.new(attrs)
            model.user_id = _user_id
            if model.file?
              model.item_id       = model.item_info :item_id
              model.item_unid     = model.item_info :item_unid
              model.item_model    = model.item_info :item_model
              model.item_name     = model.item_info :item_name
              model.operated_at   = model.item_info :operated_at
              model.operator_id   = model.item_info :operator_id
              model.operator_name = model.item_info :operator_name
            end
            model.save
          end
        end
      end

      # sync
      common_src = "#{Rails.root}/public/"
      site_src   = "#{site.public_path}/"
      if _files
        if common_include_file = create_include_pattern_file(_files, common_src.gsub(/#{Rails.root}/, '.'))
          options = _ready_options.call(common_include_file, 'common')
          result[:sites][site.id] << _rsync.call(common_src, dest, options).status

          common_include_file.unlink
        end
        if site_include_file = create_include_pattern_file(_files, site_src.gsub(/#{Rails.root}/, '.'))
          options = _ready_options.call(site_include_file, 'site')
          result[:sites][site.id] << _rsync.call(site_src, dest, options).status
          site_include_file.unlink
        end
      else
        # sync all
        options = _ready_options.call(nil, 'common')
        result[:sites][site.id] << _rsync.call(common_src, dest, options).status
        options = _ready_options.call(nil, 'site')
        result[:sites][site.id] << _rsync.call(site_src, dest, options).status
      end

    end
    result
  rescue
    nil
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

  def create_include_pattern_file(ids, node, options={})
    return nil unless ids
    return nil if ids.size <= 0

    paths = []
    Sys::TransferableFile.where(:parent_dir => node, :id => ids).each do |f|
      nodes = f.path.split('/')
      nodes.each_index do |i|
        path = nodes[0 .. i].join('/')
        path = "#{path}/" unless f.path == path
        paths << path
      end
    end
    return nil if paths.size <= 0

    require 'tempfile'
    file = Tempfile.new(['zomeki_rsync_include', '.lst'])
    begin
      paths.each {|path| file.print("+ #{path}\n") }
      file.print("- *\n")
    ensure
       file.close
       #file.unlink
    end
    file
  end

  def rsync(src, dest, options=[], &block)
    res = Rsync.run(src, dest, options)
    yield(res) if block_given?
    res
  end
end
