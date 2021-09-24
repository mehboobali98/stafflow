$(document).ready(function() {
  $(".js-available-user-leave").on("click", function() {
    let disabledFields = $(this).data('selected-leave-count');
    $(disabledFields).attr("disabled", !$(this).is(":checked"));
  });
});