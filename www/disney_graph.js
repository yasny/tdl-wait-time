var margin = {top:20, right:80, bottom:30, left:50},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

d3.csv("all_from_db.csv", function(data) {
  var series = d3.keys(data[0]).filter(function(key) { return key == "attr"; });
  var colors = d3.scale.category10();
  colors.domain(series);

  data = data.map(function(d) {
    return {
      attr: d.attr,
      date: parseDate(d.date),
      wait: +d.wait
    };
  });


  data = d3.nest().key(function(d) { return d.attr; }).entries(data);

  data.forEach(function(d) {
    d.name = d.key;
    d.color = colors(d.key);
    d.data = d.values.map(function(e) {
      return { x: e.date.valueOf()/1000, y: +e.wait };
    });
  });

  /*
  var dataSets = series.map(function(s) {
    d.forEach(function(o) { o['s'] = s; });
    return {
      name: s,
      color: colors(s),
      data: d.map(function(e) {
        console.log(e);
        return { x: parseDate(d.date), y: +d.wait };
      })
    };
  });
  */

  disney_graph(data);
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
