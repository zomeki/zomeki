function ArticleDocTabs(id) {
  this.id      = id;
  this.tabs    = null;
  this.content = null;
  this.links   = null;
  
  this.initialize = function() {
    if (this.content) return true;
    var children = $('#' + this.id).find('.tabs, .content, .links');
    var child = null;
    for (var i = 0; i < children.length; i++) {
      child = children[i];
      if (child.className.match(/(^| )tabs( |$)/)) {
        this.tabs = child;
      } else if (child.className.match(/(^| )content( |$)/)) {
        this.content = child;
      } else if (child.className.match(/(^| )links( |$)/)) {
        this.links = child;
      }
    }
  }
  
  this.show = function(name) {
    this.initialize();

    // select tab
    var tabs = $(this.tabs).find('li');
    var tab = null;
    for (var i = 0; i < tabs.length; i++) {
      tab = tabs[i];
      if (tab.className.match(new RegExp('(^| )' + name + '( |$)'))) {
        if (!tab.className.match(/(^| )current(^| )/)) {
          tab.className = name + ' current';
        }
      } else {
        tab.className = tab.className.replace(' current', '');
      }
    }
    
    // select list
    var list = $(this.content).find('ul');
    for (var i = 0; i < list.length; i++) {
      if (list[i].className == name) {
        list[i].style.display = 'block';
      } else {
        list[i].style.display = 'none';
      }
    }

    // select links
    var body = $(this.links).find('div');
    for (var i = 0; i < body.length; i++) {
      if (body[i].className == name) {
        body[i].style.display = 'block';
      } else if (body[i].className != 'feed' && body[i].className != 'more') {
        body[i].style.display = 'none';
      }
    }

    return false;
  }

  this.getTab = function(name) {
  }
}
