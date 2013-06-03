# encoding: utf-8
class ActionView::Helpers::FormBuilder
  def array_name(method)
    pos = method.index('[')

    first, second = if pos.zero?
                      [method, '']
                    else
                      [method.slice(0, pos), method.slice(pos, method.size)]
                    end

    "#{@object_name}[#{first}]#{second}"
  end

  def array_value(method)
    method = method.to_s

    unless pos = method.index('[')
      return @template.params[@object_name].try(:[], method) ||
             (@object || @template.instance_variable_get("@#{@object_name}")).try(method)
    end

    first, second = if pos.zero?
                      [method, '']
                    else
                      [method.slice(0, pos), method.slice(pos, method.size)]
                    end

    array = @template.params[@object_name].try(:[], first) ||
            (@object || @template.instance_variable_get("@#{@object_name}")).try(first)

    return array if array.nil?

    value = second.scan(/(?<=\[).*?(?=\])/).inject(array) {|result, key|
              next nil unless result.respond_to?(:[])
              result[key =~ /^\d+$/ ? key.to_i : key.to_s]
            }

    value.respond_to?(:force_encoding) ? value.force_encoding(Encoding::UTF_8) : value
  end

  def array_text_field(method, options = {})
    value  = array_value(method)
    method = array_name(method)

    @template.text_field_tag(method, value, options)
  end

  def array_select(method, choices, options = {}, html_options = {})
    options[:selected] ||= array_value(method)
    method = array_name(method)

    ## choices
    choices.each_with_index {|v,i| choices[i][1] = v[1].to_s }
    choices = @template.options_for_select(choices, options[:selected].to_s)
    options.delete(:selected)

    @template.select_tag(method, choices, options)
  end

  def select_group_with_tree(method, root, options = {})
    options[:selected] ||= array_value(method)
    method = method.to_s.index('[') ? array_name(method) : "#{@object_name}[#{method}]"

    value   = options[:value] || :id
    label   = options[:label] || :name
    order   = options[:order] || :sort_no
    cond    = options[:conditions] || {}

    choices = []
    roots = root.to_a
    if roots.size > 0
      iclass  = roots[0].class
      indstr  = '　　'
      down = lambda do |_parent, _indent|
        choices << [(indstr * _indent) + _parent.send(label), _parent.send(value).to_s]
        iclass.find(:all, :conditions => cond.merge({:parent_id => _parent.id}), :order => order).each do |_child|
          next unless _child.sites.include?(Core.site)
          down.call(_child, _indent + 1)
        end
      end
      roots.to_a.each do |item|
        next unless item.parent_id.zero? || item.sites.include?(Core.site)
        down.call(item, 0)
      end
      choices = @template.options_for_select(choices, options[:selected].to_s)
      options.delete(:selected)
    end
    options.delete(:conditions)

    return @template.select_tag(method, choices, options).html_safe
  end

  def select_with_tree(method, root, options = {})
    options[:selected] ||= array_value(method)
    method = method.to_s.index('[') ? array_name(method) : "#{@object_name}[#{method}]"

    value   = options[:value] || :id
    label   = options[:label] || :name
    order   = options[:order] || :sort_no
    cond    = options[:conditions] || {}

    roots = root.to_a
    if roots.size > 0
      choices = []
      iclass  = roots[0].class
      indstr  = '　　'
      down = lambda do |_parent, _indent|
        choices << [(indstr * _indent) + _parent.send(label), _parent.send(value).to_s]
        iclass.find(:all, :conditions => cond.merge({:parent_id => _parent.id}), :order => order).each do |_child|
          down.call(_child, _indent + 1)
        end
      end
      roots.to_a.each {|item| down.call(item, 0)}
      choices = @template.options_for_select(choices, options[:selected].to_s)
      options.delete(:selected)
    else
      choices = ''
    end
    options.delete(:conditions)

    return @template.select_tag(method, choices, options).html_safe
  end

  def radio_buttons(method, choices, options = {})
    if method.to_s.index('[')
      return array_radio_buttons(method, choices, options)
    end
    html = @template.hidden_field(@object_name, method, :value => '')
    choices.each do |label, value|
      html += radio_button(method, value, options)
      html += %Q(<label for="#{@object_name}_#{method}_#{value}">#{label}</label>).html_safe
    end
    html.html_safe
  end

  def array_radio_buttons(method, choices, options = {})
    value = array_value(method)
    method = array_name(method)

    h = ''
    choices.each do |c|
      name = "#{@object_name}[#{method}][#{c[1]}]"
      id   = "#{method.gsub(']', '').gsub('[', '_')}_#{c[1]}"
      h << @template.radio_button_tag(method, c[1], (value.to_s == c[1]))
      h << %Q(&nbsp;<label for="#{id}">#{c[0]}</label>&nbsp;)
    end
    h.html_safe
  end

  def check_boxes(method, choices, options = {})
    method = method.to_s

    checked = []
    if @template.params[@object_name] && @template.params[@object_name][method]
      @template.params[@object_name][method].each {|k, v| checked << k }
    else
      if var = @template.instance_variable_get("@#{@object_name}").send(method)
        checked = var
      end
    end

    h = ''
    choices.each do |c|
      c[1] = c[1].to_s
      name = "#{@object_name}[#{method}][#{c[1]}]"
      id   = name.gsub(/\]/, '').gsub(/\[/, '_')
      h += @template.check_box_tag(name, 1, checked.index(c[1]))
      h += %Q(<label for="#{id}">#{c[0]}</label>\n).html_safe
    end
    h.html_safe
  end

  def array_text_area(method, options = {})
    value = array_value(method)
    method = array_name(method)

    @template.text_area_tag(method, value, options)
  end
end
