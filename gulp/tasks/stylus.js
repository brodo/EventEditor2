var gulp = require('gulp');
var stylus = require('gulp-stylus');

gulp.task('stylus', function() {
  gulp.src('src/styles/style.styl')
    .pipe(stylus())
    .pipe(gulp.dest('build/css/'));

});
