$(document).ready(function() {
  $("#approve_leaves_btn").on("click", function (event) {
    let applied_leave_ids = []

    $('input[name="applied_leave_ids[]"]:checked').each(function() {
        applied_leave_ids.push(this.value)
      });
    
    $.ajax({
      type: "PATCH",
      url: "/applied_leaves/approve_multiple_leaves",
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      data: {applied_leave_ids:applied_leave_ids}
    });
  });

  $("#filter").on("change", function (event) {
    let filter_type = {};
    filter_type["filter_type"] = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/filter_applied_leaves",
      data: {filter_type}
    });
  });
});
