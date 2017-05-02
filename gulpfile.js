var gulp = require('gulp');
var rev = require('gulp-rev');
var revReplace = require('gulp-rev-replace');
var jeditor = require("gulp-json-editor");
var browserSync = require('browser-sync').create();

gulp.task('rev-rename', function() {
    return gulp
        .src([
                './public/app/app/scripts/**/*.js',
                './public/app/app/styles/**/*.css'
            ], {
                base: './public/app'
            })
        .pipe(rev()) // app.js --> app-1j8889jr.js
        .pipe(revReplace())
        .pipe(gulp.dest('./public/app/dist'))
        .pipe(rev.manifest('rev-manifest.json'))
        .pipe(gulp.dest('./public/app/dist'));
});

gulp.task('rev-edit', ['rev-rename'], function() {
    return gulp
        .src('./public/app/dist/rev-manifest.json')
        .pipe(jeditor(function(json) {
            for(var key in json) {
                json[key] = json[key].replace('app/', 'dist/app/');
            }
            return json;
        }))
        .pipe(gulp.dest('./public/app/dist/'));
});

gulp.task('build', ['rev-edit'], function() {
    var manifest = gulp.src('./public/app/dist/rev-manifest.json');
    return gulp
        .src('./public/app/app/views/index.html')
        .pipe(revReplace({manifest: manifest}))
        .pipe(gulp.dest('./public/app/app/'));
});

gulp.task('reload', ['build'], function() {
  return browserSync.reload();
})

gulp.task('init', function() {
  browserSync.init({
      proxy: 'localhost:3000',
      port: 8000,
  });
})

gulp.task('watch', ['build', 'init'], function() {
  gulp.watch('./public/app/app/**/*', ['reload'])
})
