# encoding: utf-8
module FormHelper

  ## CKEditor
  def init_ckeditor(options = {})
    settings = []

    # リードオンリーではツールバーを表示しない・リンクを動作させる
    unless (options[:toolbarStartupExpanded] = !options[:readOnly])
      settings.push(<<-EOS)
        CKEDITOR.on('instanceReady', function (e) {
          $('#cke_top_'+e.editor.name).hide();
          var links = $('#cke_contents_'+e.editor.name+' > iframe:first').contents().find('a');
          for (var i = 0; i < links.length; i++) {
            $(links[i]).click(function (ee) { location.href = ee.target.href; });
          }
        });
      EOS
    end

    settings.concat(options.map {|k, v|
      %Q(CKEDITOR.config.#{k} = #{v.kind_of?(String) ? "'#{v}'" : v};)
    })

    [ '<script type="text/javascript" src="/_common/js/ckeditor/ckeditor.js"></script>',
      javascript_tag(settings.join) ].join.html_safe
  end

  def submission_label(name)
    {
      :add       => '追加する',
      :create    => '作成する',
      :register  => '登録する',
      :edit      => '編集する',
      :update    => '更新する',
      :change    => '変更する',
      :delete    => '削除する',
      :make      => '作成する'
    }[name]
  end

  def submit(*args)
    make_tag = Proc.new do |_name, _label|
      _label ||= submission_label(_name) || _name.to_s.humanize
      submit_tag _label, :name => "commit_#{_name}"
    end
    
    h = '<div class="submitters">'
    if args[0].class == String || args[0].class == Symbol
      h += make_tag.call(args[0], args[1])
    elsif args[0].class == Hash
      args[0].each {|k, v| h += make_tag.call(k, v) }
    elsif args[0].class == Array
      args[0].each {|v, k| h += make_tag.call(k, v) }
    end
    h += '</div>'
    h.html_safe
  end
  
  def observe_field(field, params)
    on     = params[:on] ? params[:on].to_s : "change"
    url    = url_for(params[:url])
    method = params[:method] ? params[:method].to_s : 'get'
    with   = params[:with]
    update = params[:update]
    before = params[:before]
    
    data  = []
    data << "#{with}=' + encodeURIComponent($('##{field}').val()) + '" if with
    data << "authenticity_token=' + encodeURIComponent('#{form_authenticity_token}') + '" if method == 'post'
    data = data.join('&')
    
    h  = '<script type="text/javascript">' + "\n//<![CDATA[\n"
    h += "$(function() {"
    h += "$('##{field}').bind('#{on}', function() {"
    h += "#{before};" if before
    h += "jQuery.ajax({"
    h += "data:'#{data}',"
    h += "url:'#{url}',"
    h += "success:function(response){ $('##{update}').html(response) }"
    h += "})"
    h += "})"
    h += "});"
    h += "\n//]]>\n</script>"
    h.html_safe
  end
end
