function fillBoard(board, stones) {
  board.clear() // this could probably be optimized
  for (var i = 0; i < stones.length; i++) {
    stone = stones[i]
    coord = new JGOCoordinate(stone.x, stone.y);
    var jgo_color = stone.color == 0 ? JGO_BLACK : JGO_WHITE
    board.set(coord, jgo_color);
  }
}

function boardClick(coord) {
  color = $("#board").attr("side")
  game_id = $("#board").attr("game_id")
  $.post("/" + game_id + "/" + color + "/move?x=" + coord.i + "&y=" + coord.j);
}

$(document).ready(function(){ // jQuery way
  board = jgo_generateBoard($("#board"));
  board.click = boardClick;

  var pusher = new Pusher('c060ac327a245194582b'); // weiqi app key
  var channel = pusher.subscribe('my-channel');
  channel.bind('board-state-change', function(data) {
    console.log("triggered!");
    fillBoard(board, data)
  });

  game_id = $("#board").attr("game_id")
  $.ajax("/" + game_id, {
    success: function(data) { fillBoard(board, JSON.parse(data)) }
  });
});
