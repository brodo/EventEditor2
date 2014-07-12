var browserSync = require('browser-sync');
var gulp        = require('gulp');

gulp.task('browserSync', ['build'], function() {
	browserSync.init(['build/**'], {
		server: {
			baseDir: 'build'
		},
    port: 8000,
    open: false
	});
});
