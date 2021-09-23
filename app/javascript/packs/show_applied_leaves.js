$(document).ready(function() {
  toggleMassUpdateButtons();
  
  $(".js-selected-applied-leave").on("change", function() {
    toggleMassUpdateButtons();
  });

  function sendMassUpdateRequest(methodType, path, selectedLeaveIds, currentFilter) {
    $.ajax({
      type: methodType,
      url: path,
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      data: {
        applied_leave_ids: selectedLeaveIds,
        filter_type: currentFilter
      }
    });
  }

  $("#approve_leaves_btn").on("click", function(event) {
    event.preventDefault();
    let appliedLeaveIds = getSelectedLeaveIds();
    let currentFilter = getCurrentFilter();
    sendMassUpdateRequest("PATCH", "/applied_leaves/approve_leaves", appliedLeaveIds, currentFilter);
  });

  $("#reject_leaves_btn").on("click", function(event) {
    event.preventDefault();
    let appliedLeaveIds = getSelectedLeaveIds();
    let currentFilter = getCurrentFilter();
    sendMassUpdateRequest("PATCH", "/applied_leaves/reject_leaves", appliedLeaveIds, currentFilter);
  });

  function getSelectedLeaveIds() {
    let appliedLeaveIds = []
    $('.js-selected-applied-leave:checkbox:checked').each(function() {
      appliedLeaveIds.push(this.value)
    });
    return appliedLeaveIds;
  }

  function toggleMassUpdateButtons() {
    let countChecked = selectedAppliedLeavesCount();
    if (countChecked > 1) {
      $("#submit_buttons").removeClass("d-none");
    } else {
      $("#submit_buttons").addClass("d-none");
    }
  }

  function selectedAppliedLeavesCount() {
    let countChecked = $('.js-selected-applied-leave:checkbox:checked').length;
    return countChecked;
  }

  function getCurrentFilter()
  {
    return $("#filter").val();
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