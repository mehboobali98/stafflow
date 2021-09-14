$(document).ready(function(){
  $.ajax({
    type: 'GET',
    url: '/notifications',
    success: function(data, textStatus, jqXHR) {},
    error: function(jqXHR, textStatus, errorThrown) { console.log(errorThrown) }
  })
});