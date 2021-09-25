// The following script fires on event change on company_name text field. After that it 
// removes any white spaces or special characters from the company_name value and then converts it into 
// lower case before setting it to subdomain text field 
<<<<<<< HEAD
$(document).ready(function() {
  $("#company").keyup(function() {
    subdomain = $(this).val().replace(/[^A-Z0-9]/ig, "").toLowerCase();
    $('#subdomain').val(subdomain);
    $('#span_subdomain').html(subdomain);
  });
});

$(document).on('click', '.js-pagination-wrapper a', function(event) {
=======
$(document).on('click', '.pagination-wrapper a', function(event) {
>>>>>>> 84942c27e5508d5a1e48ad53c20128903b8df7bf
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
    dataType: 'script',
    success: function(response) {
      designationSelectBox.html("");
      designations = JSON.parse(response);
      designations.forEach(function(designation) {
        designationSelectBox.append(`<option value=${designation.id}> ${designation.name} </option>`)
      });
    }
  });
});
