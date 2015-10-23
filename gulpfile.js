var gulp = require('gulp');
var rev = require('gulp-rev');
var revReplace = require('gulp-rev-replace');


gulp.task('revision', function() {
    return gulp
        .src([
                './public/app/app/scripts/**/*.js',
                './public/app/app/styles/**/*.css'
            ],
            {
                base: './public/app'
            })
        .pipe(rev()) // app.js --> app-1j8889jr.js
        .pipe(revReplace())
        .pipe(gulp.dest('./public/app/dist'));
});

gulp.task('revreplace', function() {
    return gulp
        .src([
            './public/app/app/scripts/**/*.js',
            './public/app/app/styles/**/*.css'
        ],
        {
            base: './public/app'
        })
        .pipe(rev()) // app.js --> app-1j8889jr.js
        .pipe(revReplace())
        .pipe(gulp.dest('./dist'));
});
