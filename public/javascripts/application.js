$(document).ready(function() {
  
  jQuery.fn.requestedPage = function requestedPage(){
    var page    = $(this);
    var url     = page.attr('data-page-url');
    var page_id = page.attr('data-page-id');
    var timer   = null;
    var pending = true;
    
    var pollStatus = function pollStatus(){
      if (pending) {
        jQuery.ajax({
          url: '/pages/' + page_id + '.json',
          success: function(response, textStatus, jqXHR){
            if (response.pending) {
              timer = setTimeout(pollStatus, 5000);
            } else {
              pending = false;
              clearTimeout(timer);
              page.find('span.status').removeClass('pending').text('and this is what it contained:');
              
              var pre = $('<pre></pre>').css({display: 'none'});
              page.after(pre.text(response.data));
              pre.slideDown('fast');
            }
          }
        });
      }
    };
        
    pollStatus();
  };
  
  $('p.requested').requestedPage();
  
});
