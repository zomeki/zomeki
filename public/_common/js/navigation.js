/**
 * Navigation
 */
function Navigation() {
}

function Navigation_initialize(settings) {
  Navigation.settings = settings
  
  if (Navigation.settings['theme']) {
    jQuery.each(Navigation.settings['theme'], function(key, val) {
      $(key).click(function(){
        Navigation.theme(val);
        return false;
      });
    });
  }
  
  if (Navigation.settings['fontSize']) {
    jQuery.each(Navigation.settings['fontSize'], function(key, val) {
      $(key).click(function(){
        Navigation.fontSize(val);
        return false;
      });
    });
  }
  
  if (Navigation.settings['ruby']) {
    $(Navigation.settings['ruby']).click(function(){
      var flag = ($(this).attr('class') + '').match(/(^| )rubyOn( |$)/);
      Navigation.ruby( (flag ? 'off' : 'on') );
      return false;
    });
  }
  
  if (Navigation.settings['talk']) {
    $(Navigation.settings['talk']).click(function(){
      var flag = ($(this).attr('class') + '').match(/(^| )talkOn( |$)/);
      Navigation.talk( (flag ? 'off' : 'on') );
      return false;
    });
  }
  
  Navigation.theme();
  Navigation.fontSize();
  Navigation.ruby();
}
Navigation.initialize = Navigation_initialize;
  
    // if (this.settings['talk']) {
      // var k = this.settings['talk'];
      // if (k) {
        // $(this.settings['talk']).addClassName('talkOff');
        // Event.observe($(k), 'click', function(evt) {self.talk(evt); Event.stop(evt);}, false);
      // }
    // }
  
  // this.talk = function(evt) {
    // var element = Event.element(evt);
    // Navigation.talk(element, $(this.settings['player']), $(this.settings['notice']));
  // }

function Navigation_theme(theme) {
  if (theme) {
    $.cookie('navigation_theme', theme, {path: '/'});
  } else {
    theme = $.cookie('navigation_theme');
    if (!theme) return false;
  }
  $('link[title]').each(function() {
    this.disabled = true;
    if (theme == $(this).attr('title')) this.disabled = false;
  });
}
Navigation.theme = Navigation_theme;

function Navigation_fontSize(size) {
  if (size) {
    $.cookie('navigation_font_size', size, {path: '/'});
  } else {
    size = $.cookie('navigation_font_size');
    if (!size) return false;
  }
  $('body').css('font-size', size);
}
Navigation.fontSize = Navigation_fontSize;

function Navigation_ruby(flag) {
  if (!Navigation.settings['ruby']) return false;
  var elem = $(Navigation.settings['ruby']);
  if (flag == 'on') {
    $.cookie('navigation_ruby', flag, {path: '/'});
    if (location.pathname.search(/\/$/i) != -1) {
      location.href = location.pathname + "index.html.r" + location.search;
    } else if (location.pathname.search(/\.html\.mp3$/i) != -1) {
      location.href = location.pathname.replace(/\.html\.mp3$/, ".html.r") + location.search;
    } else if (location.pathname.search(/\.html$/i) != -1) {
      location.href = location.pathname.replace(/\.html$/, ".html.r") + location.search;
    } else if (location.pathname.search(/\.html$/i) != -1) {
      location.href = location.pathname.replace(/\.html$/, ".html.r") + location.search;
    } else {
      location.href = location.href.replace(/#.*/, '');
    }
  } else if (flag == 'off') {
    $.cookie('navigation_ruby', flag, {path: '/'});
    if (location.pathname.search(/\.html\.r$/i) != -1) {
      location.href = location.pathname.replace(/\.html\.r$/, ".html") + location.search;
    } else {
      location.reload();
    }
  }
  if (flag) return;
  
  if ($.cookie('navigation_ruby') == 'on') {
    if (location.pathname.search(/\/$/i) != -1) {
      location.href = location.pathname + "index.html.r" + location.search;
    } else if (location.pathname.search(/\.html$/i) != -1) {
      location.href = location.pathname.replace(/\.html/, ".html.r") + location.search;
    } else {
      elem.removeClass('rubyOff');
      elem.addClass('rubyOn');
      Navigation.notice();
    }
  } else {
    elem.removeClass('rubyOn');
    elem.addClass('rubyOff');
  }
}
Navigation.ruby = Navigation_ruby;

function Navigation_Talk(flag) {
  var player = $(Navigation.settings['player']);
  var elem   = $(Navigation.settings['talk']);
  if (!player || !elem) return false;
  
  Navigation.notice();
  
  if (flag == 'off') {
    elem.removeClass('talkOn');
    elem.addClass('talkOff');
  } else {
    elem.removeClass('talkOff');
    elem.addClass('talkOn');
  }
   
  var uri = location.pathname;
  if (uri.match(/\/$/)) uri += 'index.html';
  uri = uri.replace(/\.html\.r$/, '.html');
  
  var now   = new Date();
  var param = '?85' + now.getDay() + now.getHours();
  
  if (player) {
    uri += '.mp3' + param;
    if (player.html() == '') {
      html = '<script type="text/javascript" src="/_common/swf/niftyplayer/niftyplayer.js"></script>' +
      '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"' +
      ' codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0"' +
      ' width="165" height="37" id="niftyPlayer1" align="">' +
      '<param name=movie value="/_common/swf/niftyplayer/niftyplayer.swf?file=' + uri + '&as=1">' +
      '<param name=quality value=high>' +
      '<param name=bgcolor value=#FFFFFF>' +
      '<embed src="/_common/swf/niftyplayer/niftyplayer.swf?file=' + uri + '&as=1" quality=high bgcolor=#FFFFFF' +
      ' width="165" height="37" name="niftyPlayer1" align="" type="application/x-shockwave-flash"' +
      ' swLiveConnect="true" pluginspage="http://www.macromedia.com/go/getflashplayer">' +
      '</embed>' +
      '</object>';
      player.html(html);
    } else {
      player.html('');
      if ($.cookie('navigation_ruby') != 'on') Navigation.notice('off');
    }
  } else {
    location.href = uri;
  }
}
Navigation.talk = Navigation_Talk;

function Navigation_notice(flag) {
  var wrap   = Navigation.settings['notice'] || 'container';
  var notice = $('#navigationNotice');
  
  if (flag == 'off') {
    notice.remove();
    return false;
  }
  if (notice.size()) return false;
  
  var elem = $(Navigation.settings['notice']);
  notice = document.createElement('div'); 
  notice.id = 'navigationNotice'; 
  notice.innerHTML = 'ふりがなと読み上げ音声は，' +
    '人名，地名，用語等が正確に発音されない場合があります。';
  // $(wrap + ' *:first').before(notice);
  $('#accessibilityTool').prepend(notice);
}
Navigation.notice = Navigation_notice;
