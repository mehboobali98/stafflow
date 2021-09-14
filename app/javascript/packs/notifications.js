$(document).ready(function(){
  $.ajax({
    type: 'GET',
    accepts: 'json',
    url: '/notifications_count.json',
    success: function(data, textStatus, jqXHR){
      $('#notifications_count').html(data)
    },
    error: function(jqXHR, textStatus, errorThrown){console.log(errorThrown)}
  })

  $('#notifications_dropdown').on('shown.bs.dropdown', function(){
    $.ajax({
      type: 'GET',
      url: '/notifications',
      success: function(data, textStatus, jqXHR){console.log(data)},
      error: function(jqXHR, textStatus, errorThrown){console.log(errorThrown)}
    })
  });
});