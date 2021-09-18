$(document).ready(function() {
  $("body").on('change', '[type=checkbox]', function(event) {
    event.preventDefault();
    let disabledFieldsClassName = $(this).data('id');
    if (this.checked) //when check box is checked
    {
      $(".".concat(disabledFieldsClassName)).attr("disabled", false);
    } else {
      $(".".concat(disabledFieldsClassName)).attr("disabled", true);
    }
  });
  
  $('#user_leave_edit_form').submit(function(event){
    event.preventDefault();
    let isValid = validateUserLeaveCount();
    if (isValid==false) {
      alert("Remaining leave count cannot be greater than leave count");
      return false;
    }
  }); 
  
  function validateUserLeaveCount()
  {
    let totalCount = $('#user_leave_total_count').val();
    let remainingCount = $('#user_leave_remaining_count').val();
    return (remainingCount > totalCount) ? false : true;
  }
});