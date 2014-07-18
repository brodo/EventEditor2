var gulp = require('gulp');

gulp.task('build', [
  'generateParser',
  'browserifyMain',
  'copyHtml',
  'copyData',
  'stylus']);
