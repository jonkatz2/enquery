#' sliders
#' @title jQuery sliders for expert elicitation
#' @description Example app.
#' @param \dots Additional arguments to \code{shiny::runApp}.
#' @keywords misc
#' @export 
#' @author Jon Katz
#' @examples
#' \dontrun{ 
#' # The shiny app
#' sliders()
#' 
#' # Accepts args to shiny::runApp
#' sliders(quiet = TRUE)
#' sliders(display.mode = "showcase")
#' }


sliders <- function(...) {
  appDir <- system.file("examples", package = "enquery")
  if (appDir == "") {
    stop("Could not find directory. Try re-installing `enquery`.", call. = FALSE)
  }

  shiny::runApp(appDir, ...)
}
