$(document).ready(function() {
  $(".new_user_benefit").on("click", function(){
    $("#" + $(this).attr('data-new-user-benefit-amount')).attr("disabled", !$(this).is(":checked"));
  });
});

