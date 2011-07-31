$(document).ready(function() {
  
  jQuery.fn.requestedPage = function requestedPage(){
    var page       = $(this);
    var url        = page.attr('data-page-url');
    var page_id    = page.attr('data-page-id');
    var timer      = null;
    var pending    = true;
    var poll_count = 0;
    
    if (console && console.log) console.log('Polling status of requested page: ' + url);
    
    var pollStatus = function pollStatus(){
      if (pending) {
        poll_count++;
        
        if (console && console.log) console.log('Poll count: ' + poll_count);
        
        jQuery.ajax({
          url: '/pages/' + page_id + '.json',
          success: function(response, textStatus, jqXHR){
            if (response.pending) {
              if (console && console.log) console.log('Fetch is still pending.');
              timer = setTimeout(pollStatus, 5000);
            } else {
              if (console && console.log) console.log('Fetch complete after ' + 5 * poll_count + ' seconds.');
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
