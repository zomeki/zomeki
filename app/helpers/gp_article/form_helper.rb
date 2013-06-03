# encoding: utf-8
module GpArticle::FormHelper
  def value_for_datepicker(object_name, attribute)
    if object = instance_variable_get("@#{object_name}")
      object.send(attribute).try(:strftime, '%Y-%m-%d')
    end
  end

  def enable_datepicker_script
    s = <<-EOS
$.datepicker.regional['ja'] = {
  closeText: '閉じる',
  prevText: '前',
  nextText: '次',
  currentText: '今日',
  monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  monthNamesShort: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  dayNames: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
  dayNamesShort: ['日', '月', '火', '水', '木', '金', '土'],
  dayNamesMin: ['日', '月', '火', '水', '木', '金', '土'],
  weekHeader: '週',
  dateFormat: 'yy-mm-dd',
  firstDay: 0,
  isRTL: false,
  showMonthAfterYear: true,
  yearSuffix: '年'};
$.datepicker.setDefaults($.datepicker.regional['ja']);

$('.datepicker').datepicker();
    EOS
    s.html_safe
  end

  def value_for_datetimepicker(object_name, attribute)
    if object = instance_variable_get("@#{object_name}")
      object.send(attribute).try(:strftime, '%Y-%m-%d %H:%M')
    end
  end

  def enable_datetimepicker_script
    s = <<-EOS
$.datepicker.regional['ja'] = {
  closeText: '閉じる',
  prevText: '前',
  nextText: '次',
  currentText: '今日',
  monthNames: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  monthNamesShort: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  dayNames: ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'],
  dayNamesShort: ['日', '月', '火', '水', '木', '金', '土'],
  dayNamesMin: ['日', '月', '火', '水', '木', '金', '土'],
  weekHeader: '週',
  dateFormat: 'yy-mm-dd',
  firstDay: 0,
  isRTL: false,
  showMonthAfterYear: true,
  yearSuffix: '年'};
$.datepicker.setDefaults($.datepicker.regional['ja']);

$.timepicker.regional['ja'] = {
  timeOnlyTitle: '時刻選択',
  timeText: '時刻',
  hourText: '時',
  minuteText: '分',
  secondText: '秒',
  millisecText: 'ミリ秒',
  timezoneText: 'タイムゾーン',
  currentText: '現在',
  closeText: '閉じる',
  timeFormat: 'HH:mm',
  amNames: ['AM', 'A'],
  pmNames: ['PM', 'P'],
  isRTL: false};
$.timepicker.setDefaults($.timepicker.regional['ja']);

$('.datetimepicker').datetimepicker({
  hourGrid: 4,
  minuteGrid: 10,
  secondGrid: 10});
    EOS
    s.html_safe
  end

  def toggle_form_function
    f = <<-EOS
function toggle_form(link, target, open_label, close_label) {
  if (open_label === undefined) open_label = '開く▼';
  if (close_label === undefined) close_label = '閉じる▲';
  var l = jQuery(link);
  var t = jQuery(target);
  if (t.is(':hidden')) {
    l.html(close_label);
  } else {
    l.html(open_label);
  }
  t.slideToggle();
}
    EOS
    f.html_safe
  end

  def disable_enter_script
    s = <<-EOS
$('form').keypress(function (event) { if (event.target.type !== 'textarea' && event.which === 13) return false; });
    EOS
    s.html_safe
  end
end
