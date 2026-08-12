# Fail when the built pkgdown site references an image it does not ship.
#
# pkgdown reports "Missing images in ..." as a message and still exits 0, so a
# broken figure reaches the published site unnoticed. This checks the built
# artifact instead of parsing that log: every local <img src> in docs/ must
# resolve to a file on disk. Checking the output rather than the source avoids
# false alarms for paths pkgdown rewrites, such as index.md pointing at
# ./reference/figures/, which pkgdown copies from man/figures/.
#
# Usage: Rscript tools/check-site-images.R [site-dir]

site <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(site)) site <- "docs"

if (!dir.exists(site)) {
  stop("site directory not found: ", site, call. = FALSE)
}

html <- list.files(site, pattern = "\\.html$", recursive = TRUE,
                   full.names = TRUE)

# Local (same-site) image references only: remote URLs, protocol-relative URLs
# and inline data URIs are out of scope.
is_local <- function(src) {
  !grepl("^(https?:)?//|^data:|^#|^mailto:", src) & nzchar(src)
}

missing <- list()

for (page in html) {
  src <- regmatches(
    lines <- readLines(page, warn = FALSE),
    gregexpr("<img[^>]+src\\s*=\\s*\"[^\"]*\"", lines)
  )
  src <- sub(".*src\\s*=\\s*\"([^\"]*)\".*", "\\1", unlist(src))
  src <- src[is_local(src)]

  if (!length(src)) next

  # Drop any query string / fragment, then undo URL escaping so "%20" matches
  # the real file name.
  src <- vapply(sub("[?#].*$", "", src), utils::URLdecode, character(1),
                USE.NAMES = FALSE)

  path <- ifelse(
    startsWith(src, "/"),
    file.path(site, sub("^/", "", src)),
    file.path(dirname(page), src)
  )

  gone <- unique(src[!file.exists(path)])
  if (length(gone)) {
    missing[[page]] <- gone
  }
}

if (!length(missing)) {
  cat("All local image references resolve across", length(html), "pages.\n")
  quit(status = 0)
}

cat("Missing images in the built site:\n")
for (page in names(missing)) {
  cat("  ", sub(paste0("^", site, "/"), "", page), "\n", sep = "")
  cat(paste0("    ", missing[[page]], collapse = "\n"), "\n", sep = "")
}
quit(status = 1)
