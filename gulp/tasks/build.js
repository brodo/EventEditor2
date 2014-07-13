var gulp = require('gulp');

gulp.task('build', ['browserifyMain',
  'copyHtml',
  'copyData',
  'stylus']);
