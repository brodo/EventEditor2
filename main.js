// Generated by CoffeeScript 1.7.1
(function() {
  var addEvent, connectionList, connectorLine, createSidebar, d3, enter, eventList, eventWindow, exit, getMainRect, update, _;

  d3 = require('d3');

  createSidebar = require('./sidebar.js');

  _ = require('lodash');

  eventList = [];

  connectionList = [];

  eventWindow = require('./event_window.js')(eventList, connectionList);

  connectorLine = d3.svg.line().x(function(d) {
    return d.x;
  }).y(function(d) {
    return d.y;
  }).interpolate('basis');

  update = function() {
    eventWindow.update(eventList);
    return d3.select('#svgMain').selectAll('.connector').data(connectionList).attr('d', function(d) {
      return connectorLine(d.nodes);
    });
  };

  enter = function() {
    eventWindow.enter(eventList);
    d3.select('#svgMain').selectAll('.connector').data(connectionList).enter().append('path').attr('class', 'connector').attr('stroke', 'black').attr('stroke-width', 3).attr('fill', 'none').attr('d', function(d) {
      return connectorLine(d.nodes);
    });
    return d3.select('#svgMain').selectAll('.connector').data(connectionList).enter().append('circle').attr('cx', function(d) {
      return d.nodes[1].x;
    }).attr('cy', function(d) {
      return d.nodes[1].y;
    }).attr('r', 15);
  };

  exit = function() {
    eventWindow.exit(eventList);
    return d3.select('#svgMain').selectAll('.connector').data(connectionList).exit().remove();
  };

  addEvent = function(d, x, y) {
    var data;
    data = _.cloneDeep(d);
    data.x = Math.max(0, x - getMainRect().left - 125);
    data.y = Math.max(0, y - getMainRect().top - 125);
    data.width = eventWindow.measures.eventWidth;
    data.height = eventWindow.measures.eventWidth;
    data.andRect = function() {
      return {
        x: this.x + 5,
        y: this.y + this.height - eventWindow.measures.eventTitleHeight + 5
      };
    };
    data.andRectMiddle = function() {
      return {
        x: this.andRect().x + eventWindow.measures.combinatorButtonWidth / 2,
        y: this.andRect().y + eventWindow.measures.combinatorButtonHeight / 2
      };
    };
    eventList.push(data);
    return enter();
  };

  getMainRect = function() {
    return d3.select('#svgMain').node().getBoundingClientRect();
  };

  enter();

  d3.json("data/sensors.json", createSidebar(addEvent));

}).call(this);
