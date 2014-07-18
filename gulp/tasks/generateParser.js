var gulp = require('gulp');
var replace = require('gulp-regex-replace');
var peg = require('gulp-peg');
var handleErrors = require('../util/handleErrors');
var definitions = require('../../src/data/patterns.json');


var generatePeg = function(definitions) {
  var names, pegStatements;
  pegStatements = definitions.map(function(defition) {
    var options, returnPart, template;
    template = defition.template;
    options = defition.options.map(function(option) {
      return "\"" + option.name + "\": " + option.name;
    }).join(',');
    returnPart = "{ return { 'patternType': '"+ defition.name + "', " + options + " };}";
    return "PREDEFINED_PATTERN_" + (defition.name.toUpperCase()) + " = " + template + " " + returnPart;
  });
  names = pegStatements.map(function(s) {
    return s.split(' ')[0];
  });
  return "PREDEFINED_PATTERNS = " + (names.join('/')) + " \n" + (pegStatements.join('\n'));
};

gulp.task('generateParser', function() {
  var rules = generatePeg(definitions);
  return gulp.src('src/JSEPLParser/epl2.pegjs')
    .pipe(replace({regex:'PREDEFINED_PATTERNS = qualifyExpression', replace:rules}))
    .pipe(peg().on("error", handleErrors))
    .pipe(gulp.dest('src/JSEPLParser/'));
});
