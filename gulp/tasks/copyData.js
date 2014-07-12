var gulp = require('gulp');

gulp.task('copyData', function() {
	return gulp.src('src/data/**')
		.pipe(gulp.dest('build/data/'));
});
