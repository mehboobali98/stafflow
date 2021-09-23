$(document).ready(function() {
  $.ajax({
    type: 'GET',
    url: '/notifications/count',
    success: function(data, textStatus, jqXHR) {
      $('#notifications_count').html(data)
    },
    error: function(jqXHR, textStatus, errorThrown) { console.log(errorThrown) }
  });
});
