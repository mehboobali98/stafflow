$(document).on('turbo:load', function () {
  $('#sidebar_toggle_btn').on('click', function () {
    $('.sidebar').toggleClass('active');
    if ($('.sidebar').hasClass('active')) {
      $(".home-content").addClass("sidebar-toggle");
      $(".home-content").removeClass("home-content");
    } else {
      $(".sidebar-toggle").addClass("home-content");
      $(".home-content").removeClass("sidebar-toggle");
    }
  });
});