$(document).ready(function() {
  toggleCheckBoxVisibility();
  
  $("body").on('change', '[type=checkbox]', function(event) {
    toggleCheckBoxVisibility();
  });

  $("#approve_leaves_btn").on("click", function(event) {
    event.preventDefault();
    let appliedLeaveIds = getAppliedLeaveIds();
    let currentFilter = getCurrentFilter();
    sendMassUpdateRequest("PATCH", "/applied_leaves/approve_multiple_leaves", appliedLeaveIds, currentFilter);
  });

  $("#reject_leaves_btn").on("click", function(event) {
    event.preventDefault();
    let appliedLeaveIds = getAppliedLeaveIds();
    let currentFilter = getCurrentFilter();
    sendMassUpdateRequest("PATCH", "/applied_leaves/reject_multiple_leaves", appliedLeaveIds, currentFilter);
  });

  function toggleCheckBoxVisibility() {
    let countChecked = getCountOfCheckedBoxes();
    if (countChecked > 1) {
      $("#submit_buttons").removeClass("d-none");
    } else {
      $("#submit_buttons").addClass("d-none");
    }
  }

  function getAppliedLeaveIds() {
    let appliedLeaveIds = []
    $('input[name="applied_leave_ids[]"]:checked').each(function() {
      appliedLeaveIds.push(this.value)
    });
    return appliedLeaveIds;
  }

  function getCountOfCheckedBoxes() {
    let countChecked = $('input[name="applied_leave_ids[]"]:checked').length;
    return countChecked;
  }

  function sendMassUpdateRequest(methodType, path, data, currentFilter) {
    $.ajax({
      type: methodType,
      url: path,
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      data: {
        applied_leave_ids: data,
        filter_type: currentFilter
      }
    });
  }

  function getCurrentFilter()
  {
    return $("#filter :selected").text();
  }

  $("#filter").on("change", function(event) {
    let currentFilter = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/filter_applied_leaves",
      data: {
        filter_type: currentFilter
      }
    });
  });
});