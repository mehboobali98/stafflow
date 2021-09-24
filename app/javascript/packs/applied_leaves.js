$(document).ready(function() {
  toggleCheckBoxVisibility();
  
  $("body").on('change', '[type=checkbox]', function(event) {
    toggleCheckBoxVisibility();
  });

  $("#approve_leaves_btn").on("click", function(event) {
    event.preventDefault();
    let appliedLeaveIds = getAppliedLeaveIds();
    sendMassUpdateRequest("PATCH", "/applied_leaves/approve_multiple_leaves", applied_leave_ids);
  });

  $("#reject_leaves_btn").on("click", function(event) {
    event.preventDefault();
    let appliedLeaveIds = getAppliedLeaveIds();
    sendMassUpdateRequest("PATCH", "/applied_leaves/reject_multiple_leaves", applied_leave_ids);
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

  function sendMassUpdateRequest(methodType, path, data) {
    $.ajax({
      type: methodType,
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
    let filterType = {};
    filterType["filter_type"] = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/filter_applied_leaves",
      data: {
        filterType
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