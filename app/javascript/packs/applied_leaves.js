$(document).ready(function() {

  $("#approve_leaves_btn").hide();
  $("#reject_leaves_btn").hide();

  $("#approve_leaves_btn").on("click", function(event) {
    let applied_leave_ids = get_applied_leave_ids();
    send_mass_update_request("PATCH", "/applied_leaves/approve_multiple_leaves", applied_leave_ids);
    event.preventDefault();
  });

  $("#reject_leaves_btn").on("click", function(event) {
    let applied_leave_ids = get_applied_leave_ids();
    send_mass_update_request("PATCH", "/applied_leaves/reject_multiple_leaves", applied_leave_ids);
    event.preventDefault();
  });

  function get_applied_leave_ids() {
    let applied_leave_ids = []

    $('input[name="applied_leave_ids[]"]:checked').each(function() {
      applied_leave_ids.push(this.value)
    });
    return applied_leave_ids;
  }

  function send_mass_update_request(method_type, path, data) {
    $.ajax({
      type: method_type,
      url: path,
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      data: {
        applied_leave_ids: data
      }
    });
  }

  $("#filter").on("change", function(event) {
    let filter_type = {};
    filter_type["filter_type"] = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/filter_applied_leaves",
      data: {
        filter_type
      }
    });
  });
});

$(document).on('change', '[type=checkbox]', function(e) {
  let count_checked = $('input[name="applied_leave_ids[]"]:checked').length;
  if (count_checked > 1) {
    $("#approve_leaves_btn").show();
    $("#reject_leaves_btn").show();
  } else {
    $("#approve_leaves_btn").hide();
    $("#reject_leaves_btn").hide();
  }
});