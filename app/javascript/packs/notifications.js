$(document).ready(function() {
  $('#read-button').prop('disabled', true);

  $('#read-button').on('click', function() {
    let idsOfObjectsToMarkRead = []
    $('.js-notifications-list input:checkbox:checked').each(function() {
      idsOfObjectsToMarkRead.push(this.id)
    });
    $.ajax({
      type: 'POST',
      data: { authenticity_token: $('[name="csrf-token"]')[0].content, ids: idsOfObjectsToMarkRead },
      url: 'notifications/read'
    })
  });

  $('#select_all').on('change', function() {
    $('body .js-notifications-list input:checkbox').prop('checked', this.checked)
  });

  $('#notification_status').on('change', function() {
    $.ajax({
      type: 'GET',
      url: '/notifications',
      data: { status: this.value }
    });
  })

  $('#notification_status').val(0);

  $('body').on('change','[type=checkbox]', function() {
    if ($('.js-notifications-list input:checkbox:checked').length == 0 || $('#notification_status').val() == 1 ) {
      $('#read-button').prop('disabled', true);
      console.log('yes')
    } else {
      $('#read-button').prop('disabled', false);
    }
  });

});


$(document).on('click', '.pagination-wrapper a', function() {
  $.ajax({
    type: 'GET',
    url: this.href,
    data: { status: $('#notification_status').val() },
    dataType: 'script'
  });
  return false;
});
