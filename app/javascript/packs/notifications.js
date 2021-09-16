const { data } = require("jquery");

$(document).ready(function(){
  $.ajax({
    type: 'GET',
    url: '/notifications/count',
    success: function(data, textStatus, jqXHR) {
      console.log(data);
      $('#notifications_count').html(data)
    },
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

  $('#select_all').on('change', function() {
    $('.js-notifications-list input:checkbox').prop('checked', this.checked)
  })

  $('#notification_status').on('change', function() {
    $.ajax({
      type: 'GET',
      url: '/notifications',
      data: {status: this.value}
    })
  })

  

  $('.js-notifications-list input:checkbox').on('click', function() {
    console.log('Yes')
    if ($('.js-notifications-list input:checkbox:checked').length == 0) {
      $('#read-button').prop('disabled', true)
      console.log('yes')
    } else {
      $('#read-button').prop('disabled', false)
    }
  })

});