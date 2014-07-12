var gulp = require('gulp');
var browserify = require('../util/browserify');

gulp.task('browserifySingleEvent', function() {
	return browserify('./src/coffee/single_event/single_event_main.coffee',
		'single_event_main.js');
});
