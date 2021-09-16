$(document).ready(function(){
  $.ajax({
    type: 'GET',
    url: '/notifications',
    success: function(data, textStatus, jqXHR) {},
    error: function(jqXHR, textStatus, errorThrown) { console.log(errorThrown) }
  })

  $('#read-button').on('click', function() {
    let idsOfObjectsToMarkRead = []
    $('.js-notifications-list input:checkbox:checked').each(function() {
      idsOfObjectsToMarkRead.push(this.id)
    })
    $.ajax({
      type: 'POST',
      data: { authenticity_token: $('[name="csrf-token"]')[0].content, ids: idsOfObjectsToMarkRead },
      url: 'notifications/read'
    })
  })
});