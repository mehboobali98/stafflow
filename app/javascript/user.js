$(document).on('click', '.js-pagination-wrapper a', function(event) {
  event.preventDefault();
  $.ajax({
    type: 'GET',
    url: this.href,
    data: $('#filter_form').serialize(),
    dataType: 'script'
  });
});

$(document).on('click', '#reset_filter_btn', function(event) {
  event.preventDefault();
  $.ajax({
    type: 'GET',
    url: '/members',
    dataType: 'script'
  });
  $('.js-filter-select').val("");
});

$(document).on('change input', '.js-filter-select', function() {
  $.ajax({
    type: 'GET',
    url: '/members',
    data: $('#filter_form').serialize(),
    dataType: 'script'
  });
});

$(document).on('change', '#department_select', function() {
  if (this.value === '') return;
  let url = `/departments/${this.value}/fetch_designations`
  let designationSelectBox = $('#designation_select');
  $.ajax({
    type: 'GET',
    url: url,
    // fetch_designations answers format.json only. See show_applied_leaves.js
    // for why asking for a script stopped working at jQuery 4.
    dataType: 'json',
    success: function(designations) {
      designationSelectBox.html("");
      designations.forEach(function(designation) {
        designationSelectBox.append(`<option value=${designation.id}> ${designation.name} </option>`)
      });
    }
  });
});
