// The following script fires on event change on company_name text field. After that it 
// removes any white spaces or special characters from the company_name value and then converts it into 
// lower case before setting it to subdomain text field 
$(document).ready(function() {
  $("#company").keyup(function() {
    subdomain = $(this).val().replace(/[^A-Z0-9]/ig, "").toLowerCase();
    $('#subdomain').val(subdomain);
    $('#span_subdomain').html(subdomain);
  });
});

$(document).on('click', '.pagination-wrapper a', function(event) {
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
  $.ajax({
    type: 'GET',
    url: `/departments/${this.value}/designations`,
    dataType: 'script',
    success: function(response) {
      designationSelectBox = $('#designation_select');
      designationSelectBox.html("");
      designations = JSON.parse(response);
      designations.forEach(function(designation) {
        designationSelectBox.append(`<option value=${designation.id}> ${designation.name} </option>`)
      });
    }
  });
});

$(function() {
  if(window.location.pathname.indexOf('edit') >= 0) {
    if($('#department_select').val()) {
      $.ajax({
        type: 'GET',
        url: `/departments/${$('#department_select').val()}/designations`,
        dataType: 'script',
        success: function(response) {
          designationSelectBox = $('#designation_select');
          designationSelectBox.html("");
          designations = JSON.parse(response);
          designations.forEach(function(designation) {
            designationSelectBox.append(`<option value=${designation.id}> ${designation.name} </option>`)
          });
        }
      });
    }
  }
})