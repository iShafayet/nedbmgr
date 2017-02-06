
### =======================================
## Build Script
## Originally created by Sayem Shafayet
## extended by ParticleIT
======================================= ###

gulp = require('gulp')
gutil = require('gulp-util')
connect = require('gulp-connect')
uglify = require('gulp-uglify')
less = require('gulp-less')
minifyCSS = require('gulp-minify-css')
minifyHTML = require('gulp-minify-html')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
sourcemaps = require('gulp-sourcemaps')
changed = require('gulp-changed')
stylus = require('gulp-stylus')
webserver = require('gulp-webserver')
htmlhint = require("gulp-htmlhint")
runSequence = require('run-sequence')
del = require('del')
rename = require("gulp-rename")

pathlib = require 'path'
modify = require('gulp-modify')
changed = require('gulp-changed')

os = require('os')

###
  The debug build process - 
    1. delete the build-debug directory
    2. copy all contents from src to build-debug
    3. in the [ '/assets', '/elements', '/', 'vendor-assets' ] directories under 'build-debug': 
      a) compile all *.coffee files and generate source maps
    4. keep watch and redo the tasks as necessary
###

paths = 
  src:
    all: [ 'src/**' ]
    allButBower: [ 'src/**', '!src/bower-assets/**']
  debug:
    root: '.build-debug'
    coffee: [
      '.build-debug/assets/*.coffee'
      # '.build-debug/static-data/*.coffee'
      '.build-debug/behaviors/*.coffee'
      '.build-debug/vendor-assets/*.coffee'
      '.build-debug/elements/*/*.coffee'
    ]

gulp.task 'clean-debug', ->
  return del paths.debug.root

gulp.task 'copy-debug', ->
  return gulp.src paths.src.all
  .pipe changed paths.debug.root
  .pipe gulp.dest paths.debug.root

gulp.task 'copy-debug-watch', ->
  return gulp.src paths.src.allButBower
  .pipe changed paths.debug.root
  .pipe gulp.dest paths.debug.root

gulp.task 'build-debug-coffee', ->
  return gulp.src paths.debug.coffee
  .pipe(sourcemaps.init())
  .pipe(coffee({bare: false}).on('error', gutil.log))
  # .pipe(uglify())
  .pipe(sourcemaps.write('.'))
  .pipe rename (path)->
    if path.extname is '.map'
      path.basename = path.basename.replace '.js', '.coffee-compiled.js'
    else if path.extname is '.js'
      path.basename = path.basename += '.coffee-compiled'
    else
      throw new Error 'Unknown Error 1'
    return path
  .pipe modify {
    fileModifier: (vfd, contents)->
      if (''+vfd.path).indexOf('.js.map') > -1
        json = JSON.parse contents
        json.file = json.file.replace '.js', '.coffee-compiled.js'
        contents = JSON.stringify json
      else if (''+vfd.path).indexOf('.js') > -1
        index = contents.indexOf 'sourceMappingURL='
        contents = contents.substr 0, (index + ('sourceMappingURL='.length))
        contents += pathlib.basename(vfd.path)+'.map'
      return contents
  }
  .pipe gulp.dest (vfd)->
    dirname = (pathlib.dirname vfd.path)
    sep = (if os.platform() is 'win32' then '\\' else '/')
    if dirname.indexOf('elements'+ sep) > -1
      dirname = dirname.split sep
      dirname.pop()
      dirname = dirname.join sep
    return dirname

gulp.task 'build-debug', (cbfn)->
  runSequence 'clean-debug', 'copy-debug', 'build-debug-coffee', cbfn
  return

gulp.task 'watch', ->
  gulp.watch paths.debug.coffee, ['build-debug-coffee']
  # gulp.watch paths.src.all, ['copy-debug']
  gulp.watch paths.src.allButBower, ['copy-debug-watch']

gulp.task 'serve-debug', ->
  gulp.src paths.debug.root
  .pipe webserver {
    livereload: false
    directoryListing: false
    host: '127.0.0.1'
    port: 8502
    open: false
    fallback: '404.html'
  }
  return

gulp.task 'default', (cbfn)->
  runSequence 'build-debug', 'serve-debug', 'watch', cbfn
  return


