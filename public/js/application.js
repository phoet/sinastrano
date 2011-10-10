var SINASTRANO = {
  tail: function() {
    if (SINASTRANO.pollingEnabled) {
      $.get('/tail', function(data) {
        if ($('#log textarea').attr('value') != data) {
          $('#log textarea').attr('value', data);
        }
      });
    }
    setTimeout(SINASTRANO.tail, SINASTRANO.pollingFrequency);
  },
  
  pollingFrequency: 2000,
  
  handleFrequency: function() {
    var text = $(this).html();
    if (text == 'fast') {
      SINASTRANO.pollingFrequency = 1000;
    } else if (text == 'medium') {
      SINASTRANO.pollingFrequency = 2000;
    } else if (text == 'slow') {
      SINASTRANO.pollingFrequency = 3000;
    }
  },
  
  pollingEnabled: true,
  
  togglePolling: function() {
    SINASTRANO.pollingEnabled = !SINASTRANO.pollingEnabled;
    $(this).html(SINASTRANO.pollingEnabled ? 'stop' : 'start');
  },
  
  deployForm: function(e) {
    e.preventDefault();
    if($('select[name="rev"]').val() === "") {
      alert("Please select a revision!");
      return;
    }
    $('input:submit').attr("disabled", true);
    $("#spinner").show();
    SINASTRANO.pollingEnabled = true;
    $.post($(this).attr('action'), $(this).serialize(), function() {
      $("#spinner").hide();
      $('input:submit').attr("disabled", false);
    });
  }
};

$(document).ready(function(){
  SINASTRANO.tail();
  $(".freq").click(SINASTRANO.handleFrequency);
  $("#toggle_polling").click(SINASTRANO.togglePolling);
  $("#deploy_form").bind("submit", SINASTRANO.deployForm);
});
