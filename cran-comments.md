## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
* I kept only 1 vignette within doc (Getting started) as it is very large to due to the underlying JavaScript [dependencies](https://github.com/antvis/G6) (the dependency would be typically copied for each vignette which can easily grow to 10MB). I have no way to reduce the size further as I am not maintainer of the G6 JavaScript API. The g6R JavaScript assets have been minimized as much as possible using standard JS minification techniques powered by webpack.

### Resubmission

* Fixed DESCRIPTION spaces.
* Add missing `@return` to `JS()` documentation.
* Do not use `dontrun` in roxygen doc. Replaced by `if (interactive())` in some contexts.
