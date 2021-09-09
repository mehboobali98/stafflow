$(document).ready(function(){
 $("#approve_leaves_btn").on("click", function(event) {
   let applied_leave_ids = $('#applied_leaves_form').serializeArray();
    $.ajax({
        type: "PATCH",
        url: $('#applied_leave_form').attr('action'), //sumbits it to the given url of the form
        data: applied_leave_ids,
        dataType: "JSON",
        success: function(json) {
         console.log("success", json)
        }
    //return false; // prevents normal behaviour
  });
});
