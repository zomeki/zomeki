function enable_tabs() {
  var tabs = $('#tabs > li');
  var tab_contents = $('#tab_contents > div');

  var index;
  tabs.on('click', function () {
    if (index != tabs.index(this)) {
      index = tabs.index(this);
      tab_contents.hide().eq(index).fadeIn('fast');
      tabs.removeClass('current').eq(index).addClass('current');

      if (me) {
        google.maps.event.trigger(me.map, 'resize');
      }
    }
  });

  $(tabs[0]).trigger('click');
}
