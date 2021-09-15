$(document).ready(function() {
  $("#event_form").on('submit', function(event) {
    let eventDate = $("#event_date").val();
    if (validateDateFormat(eventDate) && validateDateYear(eventDate)) {
      return true;
    }else{
      alert("Invalid event date")
      return false;
    }
  });

  function validateDateFormat(eventDate)
  {
    // format: yyyy/mm/dd
    let dateRegex = /(^[0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2})$/;
    return dateRegex.test(eventDate);
  }

  function validateDateYear(eventDate)
  {
    let eventYear = new Date(eventDate).getFullYear();
    if(isNaN(eventYear) || eventYear.toString().length > 4){
      return false;
    }
    return true;
  }
});