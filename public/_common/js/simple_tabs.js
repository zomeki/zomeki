function enable_simple_tabs() {
  var simple_tabs = $('#simple_tabs > li');
  var simple_tab_panels = $('#simple_tab_panels > div');

  var index;
  simple_tabs.on('click', function () {
    if (index != simple_tabs.index(this)) {
      index = simple_tabs.index(this);
      simple_tab_panels.hide().eq(index).show();
      simple_tabs.removeClass('current').eq(index).addClass('current');
    }
  });

  $(simple_tabs[0]).trigger('click');
}
