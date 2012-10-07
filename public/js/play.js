$(document).ready(function(){ // jQuery way
  board = jgo_generateBoard($("#board"));
  board.click = boardClick;

  $.ajax("/game/0", {
    success:
    function(data) {
      var nodes = JSON.parse(data)
      for (var i = 0; i < nodes.length; i++) {
        node = nodes[i]
        coord = new JGOCoordinate(node.x, node.y);
        var jgo_color = node.color == 0 ? JGO_BLACK : JGO_WHITE
        board.set(coord, jgo_color);
      }
    }
  });
});

function boardClick(coord) {
  color = $("#board").attr("side")
  $.post("/game/0/" + color + "/move?x=" + coord.i + "&y=" + coord.j, {
    success: function(data) { board.set(coord, color == "0" ? JGO_BLACK : JGO_WHITE); }
  });
}
