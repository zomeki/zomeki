
$(function() {
  $('#currentNaviSite').click(function(){
    $('#naviConcepts').hide();
    
    var view = $('#naviSites');
    if (view.attr('id')) {
      view.toggle();
    } else {
      if (this.loading) return false;
      this.loading = true;
      
      var uri = $(this).attr('href');
      jQuery.ajax({
        url: uri,
        success: function(data, dataType) {
          $('#content').prepend(data);
          addHandler_onClickConceptIcon();
        }
      });
    }
    return false;
  });
  
  $('#currentNaviConcept').click(function(){
    $('#naviSites').hide();
    
    var view = $('#naviConcepts');
    if (view.attr('id')) {
      view.toggle();
    } else {
      if (this.loading) return false;
      this.loading = true;
      
      var uri = $(this).attr('href');
      jQuery.ajax({
        url: uri,
        success: function(data, dataType) {
          $('#content').prepend(data);
          addHandler_onClickConceptIcon();
        }
      });
    }
    return false;
  });
  
  addHandler_onClickConceptIcon();
});

function addHandler_onClickConceptIcon() {
  $('#naviConcepts a.icon').click(function(){
    var iconId = $(this).attr('id');
    var listId = iconId.replace(/Icon/, 'List');
    $('#' + listId).toggle();
    if (mark = $('#' + listId).css('display') == 'none') {
      $('#' + iconId).html('+');
      $('#' + iconId).addClass('closedChildren');
      $('#' + iconId).removeClass('openedChildren');
    } else {
      $('#' + iconId).html('-');
      $('#' + iconId).addClass('openedChildren');
      $('#' + iconId).removeClass('closedChildren');
    }
    return false;
  });
}
