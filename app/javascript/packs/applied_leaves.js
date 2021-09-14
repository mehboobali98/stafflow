$(document).ready(function() {

  toggle_check_box_vibility();
  
  $("body").on('change', '[type=checkbox]', function(e) {
    toggle_check_box_vibility();
  });

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

  function toggle_check_box_vibility() {
    let count_checked = get_count_of_checked_boxes();
    if (count_checked > 1) {
      $("#submit_buttons").removeClass("d-none");
    } else {
      $("#submit_buttons").addClass("d-none");
    }
  }

  function get_applied_leave_ids() {
    let applied_leave_ids = []

    $('input[name="applied_leave_ids[]"]:checked').each(function() {
      applied_leave_ids.push(this.value)
    });
    return applied_leave_ids;
  }

  function get_count_of_checked_boxes() {
    let count_checked = $('input[name="applied_leave_ids[]"]:checked').length;
    return count_checked;
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