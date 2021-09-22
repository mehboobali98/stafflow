$(document).ready(function() {
  $(".js-available-user-leave").on("click", function() {
    let disabledFieldsClassName = $(this).data('selected-leave-count');
    $(disabledFieldsClassName).attr("disabled", !$(this).is(":checked"));
  });

  $('#user_leave_edit_form').submit(function(event) {
    event.preventDefault();
    let isValid = validateUserLeaveCount();
    if (isValid == false) {
      alert("Remaining leave count cannot be greater than leave count");
      return false;
    }
  });

  function validateUserLeaveCount() {
    let totalCount = $('#user_leave_total_count').val();
    let remainingCount = $('#user_leave_remaining_count').val();
    return (remainingCount > totalCount) ? false : true;
  }
});