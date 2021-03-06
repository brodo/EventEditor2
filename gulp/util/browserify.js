/* browserify util
   ---------------
   Bundle javascripty things with browserify!

   If the watch task is running, this uses watchify instead
   of browserify for faster bundling using caching.
*/

var browserify   = require('browserify');
var watchify     = require('watchify');
var bundleLogger = require('./bundleLogger');
var gulp         = require('gulp');
var handleErrors = require('./handleErrors');
var source       = require('vinyl-source-stream');
var uglify       = require('gulp-uglify');
var gulpif       = require('gulp-if')
var streamify    = require('gulp-streamify');

module.exports = function (src, target) {
  var bundleMethod = global.isWatching ? watchify : browserify;

  var bundler = bundleMethod({
    // Specify the entry point of your app
    entries: [src],
    // Add file extentions to make optional in your requires
    extensions: ['.coffee', '.hbs']
  });

  var bundle = function() {
    // Log when bundling starts
    bundleLogger.start();

    return bundler
      // Enable source maps!
      .bundle(global.isWatching ? {debug: true} : {})
      // Report compile errors
      .on('error', handleErrors)
      // Use vinyl-source-stream to make the
      // stream gulp compatible. Specifiy the
      // desired output filename here.
      .pipe(source(target))
      .pipe(gulpif(!global.isWatching, streamify(uglify())))
      // Specify the output destination
      .pipe(gulp.dest('./build/js/'))
      // Log when bundling completes!
      .on('end', bundleLogger.end);
  };

  if(global.isWatching) {
    // Rebundle with watchify on changes.
    bundler.on('update', bundle);
  }

  return bundle();
}