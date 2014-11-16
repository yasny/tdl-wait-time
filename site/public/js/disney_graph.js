var margin = {top:20, right:80, bottom:30, left:50},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

d3.json("/disney/waittime", function(error, json) {
  if (error) return console.warn(error);
  var series = d3.keys(json[0]).filter(function(key) { return key == "attraction_name"; });
  var colors = d3.scale.category10();

  json = d3.nest().key(function(d) { return d.attraction_name; }).entries(json);

  json.forEach(function(d) {
    d.name = d.key;
    d.color = colors(d.key);
    d.data = d.values.map(function(e) {
      return { x: parseDate(e.datetime)/1000, y: +e.wait };
    });
  });

  disney_graph(json);
});


var disney_graph = function(sets) {
  var graph = new Rickshaw.Graph( {
    element: document.querySelector("#chart"),
    renderer: "line",
    width: width,
    height: height,
    series: sets
  });

  var time = new Rickshaw.Fixtures.Time.Local();
  var months = time.unit("day");
  var x_axis = new Rickshaw.Graph.Axis.Time({
    graph: graph,
    timeFixture: time,
  });

  var y_axis = new Rickshaw.Graph.Axis.Y({
    graph: graph,
    orientation: "left",
    tickFormat: function(y) { return y.toString()+"分"; },
    element: document.getElementById('y_axis'),
  });

  var legend = new Rickshaw.Graph.Legend({
    element: document.getElementById("legend"),
    graph: graph,
  });

  graph.render();

  var hoverDetail = new Rickshaw.Graph.HoverDetail( {
    graph: graph,
    xFormatter: function(x) { return new Date(x * 1000).toLocaleString(); },
    yFormatter: function(y) { return y.toString() + "分"; }
  });

  var shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
    graph: graph,
    legend: legend
  });

  var highlighter = new Rickshaw.Graph.Behavior.Series.Highlight( {
    graph: graph,
    legend: legend
  });

  var preview = new Rickshaw.Graph.RangeSlider( {
    graph: graph,
    element: document.getElementById('preview'),
  });

  var previewXAxis = new Rickshaw.Graph.Axis.Time({
    graph: preview.graph,
    timeFixture: new Rickshaw.Fixtures.Time.Local(),
    ticksTreatment: "glow"
  });

  previewXAxis.render();
};
