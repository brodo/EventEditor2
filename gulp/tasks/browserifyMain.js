var gulp = require('gulp');
var browserify = require('../util/browserify');

gulp.task('browserifyMain', function() {
	return browserify('./src/coffee/main.coffee',
		'main.js');
});
