const gulp       = require('gulp')
const gettext    = require('gulp-gettext')

gulp.task('gettext', () => {
    gulp.src('./languages/*.po')
        .pipe(gettext())
        .pipe(gulp.dest('./languages/'));
})
