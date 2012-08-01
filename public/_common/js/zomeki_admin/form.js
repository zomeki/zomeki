
jQuery.extend(jQuery.fn, {
  // toggle open
  toggleOpen: function(target, openLabel, closeLabel) {
    if (!openLabel)  openLabel  = "開く▼";
    if (!closeLabel) closeLabel = "閉じる▲";
    if (jQuery(target).css('display') == 'none') {
      jQuery(this).html(closeLabel);
    } else {
      jQuery(this).html(openLabel);
    }
    jQuery(target).toggle();
  }
});
