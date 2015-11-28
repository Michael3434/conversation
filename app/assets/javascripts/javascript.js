$(document).ready(function() {
  $('#form-for-img').on('change', function(){
    $(this).submit();
  });
$('#select').on('change', function(){
    $('#btn-select').removeClass('btn-select-hide')
  });
});

