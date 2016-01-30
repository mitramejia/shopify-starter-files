# =============================================================
#
# Name: Gulpfile
# -> Description: Gulp tasks like watch, liverload and shopify deployments.
#
# Author: mitramejia 
# Created at: 11/18/15
#
# =============================================================

# Gulp plugin setup
gulp = require 'gulp'
watch = require 'gulp-watch'
fs = require 'fs'
gutil = require 'gulp-util'
livereload = require 'gulp-livereload'
gulpShopify = require 'gulp-shopify-upload'
checkBranch = require 'check-branch'

# Get your Shopify settings from dev-settings.json
shopifySettings = JSON.parse fs.readFileSync './dev-settings.json'
apiKey = shopifySettings.SHOPIFY_API_KEY  
apiPassword = shopifySettings.SHOPIFY_API_PASSWORD 
storeUrl = shopifySettings.SHOPIFY_STORE_URL
themeId = shopifySettings.SHOPIFY_THEME_ID
localThemeDir = './+(assets|layout|config|snippets|templates|locales)/**'

gulp.task 'deploy', ->
    checkBranch('master').then((result) ->
      if result.success
        gutil.log "On branch #{gutil.colors.blue.bold result.detail}" 
        gutil.log "Deploying to #{gutil.colors.blue.bold 'Production Theme'} #{gutil.colors.dim themeId.production}"
        return gulp.src(localThemeDir).pipe(gulpShopify(apiKey, apiPassword, storeUrl, themeId.production)) 
      else 
        gutil.log "On branch #{gutil.colors.blue.bold result.detail}"
        gutil.log "Deploying to #{gutil.colors.blue.bold 'Development Theme'} #{gutil.colors.dim themeId.development}"
        return gulp.src(localThemeDir).pipe(gulpShopify(apiKey, apiPassword, storeUrl, themeId.development))
    , (error) -> console.error error)

# Watch for changes on theme files, uploads those changes to the development theme and reloads the browser
gulp.task 'watch-shopify', ->
  watch(localThemeDir)
  .pipe(gulpShopify(apiKey, apiPassword, storeUrl, themeId.development)
  ).pipe livereload(
    start: true
    quiet: true
    )

# Default gulp action when gulp is run
gulp.task 'default', [ 'watch-shopify' ]
