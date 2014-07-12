var gulp = require('gulp');

gulp.task('build', ['browserifySingleEvent',
  'browserifyEventList',
  'copyHtml',
  'copyData',
  'stylus']);
