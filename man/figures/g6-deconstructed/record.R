# Record the deck to timestamped JPEG frames via the DevTools screencast
# (the live compositor stream, which - unlike $screenshot() - keeps painting
# across multiple Reveal navigations). Frames + timestamps -> ffmpeg concat.
library(chromote); library(later)
unlink(".frames", recursive = TRUE); dir.create(".frames")

b <- ChromoteSession$new()
b$Page$navigate(paste0("file://", normalizePath("g6-deconstructed.html")))
b$Page$loadEventFired(); b$set_viewport_size(1280, 720); Sys.sleep(2)
b$Runtime$evaluate("Reveal.slide(1)")                                  # content slide, flat
b$Runtime$evaluate("var t=document.getElementById('title-slide'); if(t) t.remove();")
Sys.sleep(0.5)

st <- new.env(); st$i <- 0L; st$ts <- numeric()
b$Page$screencastFrame(callback = function(p) {
  st$i <- st$i + 1L
  writeBin(base64enc::base64decode(p$data), sprintf(".frames/%04d.jpg", st$i))
  st$ts[st$i] <- p$metadata$timestamp
  try(b$Page$screencastFrameAck(sessionId = p$sessionId), silent = TRUE)
})
pump <- function(sec) { t <- Sys.time(); while (as.numeric(Sys.time() - t) < sec) later::run_now(0.04) }

b$Page$startScreencast(format = "jpeg", quality = 82, everyNthFrame = 1L)
pump(1.2)                                            # hold flat
for (k in 0:8) { b$Runtime$evaluate(sprintf("Reveal.slide(0,0,%d)", k)); pump(if (k <= 1) 1.5 else 1.2) }
pump(1.0)                                            # hold finished
b$Page$stopScreencast()
Sys.sleep(0.3); later::run_now(0.2)
b$close()

# write ffmpeg concat list with real per-frame durations
ts <- st$ts[seq_len(st$i)]
durs <- c(diff(ts), 0.1)
durs[durs <= 0 | is.na(durs)] <- 0.03
lines <- c(sprintf("file '%04d.jpg'\nduration %.3f", seq_len(st$i), durs))
writeLines(c(lines, sprintf("file '%04d.jpg'", st$i)), ".frames/concat.txt")
cat("frames:", st$i, " total secs:", round(sum(durs), 1), "\n")

# assemble the GIF (palette then paletteuse for clean colors), cropping out the
# Reveal menu/progress chrome. Output to the shipped figure path.
crop <- "crop=1260:600:10:50"
out <- "../g6R-deconstructed.gif"
system2("ffmpeg", c("-y", "-f", "concat", "-safe", "0", "-i", ".frames/concat.txt",
  "-vf", sprintf("%s,fps=15,scale=860:-1:flags=lanczos,palettegen=max_colors=128:stats_mode=diff", crop),
  ".frames/palette.png"))
system2("ffmpeg", c("-y", "-f", "concat", "-safe", "0", "-i", ".frames/concat.txt",
  "-i", ".frames/palette.png", "-lavfi",
  sprintf("%s,fps=15,scale=860:-1:flags=lanczos[x];[x][1:p]paletteuse=dither=bayer:bayer_scale=3", crop),
  out))
cat("wrote", normalizePath(out), "\n")
