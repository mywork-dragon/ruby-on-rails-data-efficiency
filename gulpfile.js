var gulp = require('gulp');
var rev = require('gulp-rev');
var revReplace = require('gulp-rev-replace');


gulp.task('revision', function() {
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

gulp.task('revreplace', function() {
    var manifest = gulp.src('./public/app/dist/rev-manifest.json');
    return gulp.src('./public/app/app/views/index.html')
        .pipe(revReplace({manifest: manifest}))
        .pipe(gulp.dest('./public/app/app/'));
});
