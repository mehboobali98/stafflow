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

  $("body").on('select2:select', '#applied_leave_member_id', function(event) {
    let user = {};
    user["member_id"] = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/get_user_leaves",
      dataType: 'script',
      data: {
        user
      },
      success:function(response){
        leavesSelectBox = $('#leaves_select');
        leavesSelectBox.html("");
        leaves = JSON.parse(response);
        leaves.forEach(function(leave) {
          leavesSelectBox.append(`<option value=${leave.id}> ${leave.name} </option>`)
        });
      }
    });
  });

  $("body").on('keyup', '.select2-search__field', function(event) {
    let user = {};
    user["email"] = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/get_users_list",
      dataType: 'script',
      data: {
        user
      },
      success:function(response){
        employeesSelectBox = $('#applied_leave_member_id');
        users = JSON.parse(response);
        users.forEach(function(user) {
          if ($(`#applied_leave_member_id option[value=${user.id}]`).length == 0){
              employeesSelectBox.append(`<option value=${user.id}> ${user.email} </option>`);
          }
        });
      }
    });
  });
});