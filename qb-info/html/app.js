QBInfo = {};

$(document).ready(function () {
  window.addEventListener("message", function (event) {
    switch (event.data.action) {
      case "open":
        QBInfo.Open(event.data);
        break;
      case "close":
        QBInfo.Close();
        break;
    }
  });
});

QBInfo.Open = function (data) {
  $(".scoreboard-block").fadeIn(500);
  var InfoObject = $(".scoreboard-info");

  $(InfoObject).html("");

  if (data.info.header != null) {
    $(".scoreboard-header").html(
      "<p>" + data.info.header + "</p>"
    );
  } else {
    $('.scoreboard-header').hide();
  }

  $.each(data.info.DataInfo, function (i, info) {
    var InfoElement = '<div class="info-beam-title"><p>' + data.info.DataInfo[i] + '</p></div>'
    $(InfoObject).append(InfoElement);
  });
};

QBInfo.Close = function () {
  $(".scoreboard-block").fadeOut(500);
};
