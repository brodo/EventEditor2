var gulp = require('gulp');
var browserify = require('../util/browserify');

gulp.task('browserifyEventList', function() {
	return browserify('./src/coffee/event_list/events_list_main.coffee',
		'events_list_main.js');
});
