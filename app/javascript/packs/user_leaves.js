$(document).on('change', '[type=checkbox]', function(e) {
  let number_field_id = e.target.id.split('_').slice(0, 4).join("_").concat("_total_count");
  if (this.checked) //when check box is checked
  {
    $("#".concat(number_field_id)).attr("disabled", false);
  } else {
    $("#".concat(number_field_id)).attr("disabled", true);
  }
});