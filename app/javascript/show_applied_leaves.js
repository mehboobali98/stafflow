$(document).ready(function() {
  $("body").on('select2:select', '#applied_leave_member_id', function(event) {
    let member_id = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/get_available_user_leaves",
      dataType: 'json',
      data: {
        member_id
      },
      success: function(leaves) {
        leavesSelectBox = $('#leaves_select');
        leavesSelectBox.html("");
        leaves.forEach(function(leave) {
          leavesSelectBox.append(`<option value=${leave.id}> ${leave.name} </option>`)
        });
      }
    });
  });

  $("body").on('keyup', '.select2-search__field', function(event) {
    let query = this.value;
    $.ajax({
      type: "GET",
      url: "/applied_leaves/search_users",
      dataType: 'json',
      data: {
        query
      },
      success: function(users) {
        employeesSelectBox = $('#applied_leave_member_id');
        users.forEach(function(user) {
          if ($(`#applied_leave_member_id option[value=${user.id}]`).length == 0) {
            employeesSelectBox.append(`<option value=${user.id}> ${user.email} </option>`);
          }
        });
      }
    });
  });

  $("#applied_leave_member_id").select2({
    theme: "classic",
    dropdownCssClass: 'select-dropdown',
    width: '100%'
  });
});
