var gulp = require('gulp');

gulp.task('copyHtml', function() {
	return gulp.src('src/html/**')
		.pipe(gulp.dest('build'));
});
