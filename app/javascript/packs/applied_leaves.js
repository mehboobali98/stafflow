$(document).ready(function() {
  $("#approve_leaves_btn").on("click", function (event) {
    let applied_leave_ids = $('#applied_leaves_form').serializeArray();
    console.log("hello")
    $.ajax({
      type: "PATCH",
      url: $('#applied_leave_form').attr('action'), //sumbits it to the given url of the form
      data: applied_leave_ids
    });
  });

  $("#filter").on("change", function (event) {
    let filter_type = {};
    filter_type["filter_type"] = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/filter_applied_leaves",
      data: filter_type
    });
  });
});
