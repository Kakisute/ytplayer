gulp        = require 'gulp'
notify      = require 'gulp-notify'
rename      = require 'gulp-rename'
browserify  = require 'gulp-browserify'
sass        = require 'gulp-sass'
haml        = require 'gulp-haml'
coffee      = require 'gulp-coffee'
#electron    = require 'gulp-electron'
#packageJson = require './package.json'

handleErrors = ->
  args = Array.prototype.slice.call arguments
  notify.onError(
    title: "Compile Error",
    message: "<%= error %>"
  ).apply this, args
  this.emit 'end'

gulp.task 'build:renderer', ->
  gulp.src './src/coffee/renderer/app.coffee', {read: false}
    .pipe browserify
      transform: ['coffee-reactify']
      extensions: ['.coffee']
    .on 'error', handleErrors
    .pipe rename 'app.js'
    .pipe gulp.dest 'dest/js/renderer'

gulp.task 'build:browser', ->
  gulp.src './src/coffee/browser/*.coffee'
    .pipe coffee()
    .on 'error', handleErrors
    .pipe gulp.dest 'dest/js/browser'

gulp.task 'build:scss', ->
  gulp.src 'src/scss/*.scss'
    .pipe sass()
    .on 'error', handleErrors
    .pipe gulp.dest 'dest/css'

gulp.task 'build:haml', ->
  gulp.src 'src/haml/index.haml'
    .pipe haml()
    .on 'error', handleErrors
    .pipe gulp.dest '.'

gulp.task 'default', ['build']
gulp.task 'build', [
  'build:renderer'
  'build:browser'
  'build:scss'
  'build:haml'
]

gulp.task 'watch', ['build'], ->
  gulp.watch 'src/coffee/renderer/*.coffee', ['build:renderer']
  gulp.watch 'src/coffee/browser/*.coffee', ['build:browser']
  gulp.watch 'src/scss/*.scss', ['build:scss']
  gulp.watch 'src/haml/*.haml', ['build:haml']
