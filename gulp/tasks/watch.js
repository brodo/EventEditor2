var gulp = require('gulp');

gulp.task('watch', ['setWatch', 'browserSync'], function() {
  gulp.watch('src/data/**',['generateParser']);
  gulp.watch('src/styles/**',['stylus']);
  gulp.watch('src/html/**', ['copyHtml']);
	gulp.watch('src/data/**', ['copyData']);
	// Note: The browserify task handles js recompiling with watchify
});
