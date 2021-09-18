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
})

$(document).on('change', '.js-filter-select', function() {
  $.ajax({
    type: 'GET',
    url: '/members',
    data: $('#filter_form').serialize(),
    dataType: 'script'
  });
})