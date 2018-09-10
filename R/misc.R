.onAttach <- function(...) {
  # Create link to javascript and css files for package
  shiny::addResourcePath("enquery", system.file("www", package="enquery"))
  
  shiny::addResourcePath("jquery-ui", system.file("shared/jquery-ui-1.12.1.default", package="enquery"))
  
}

enqueryDep <- htmltools::htmlDependency("enqueryDep", packageVersion("enquery"), src = c("href" = "enquery"), script = "enquery.js", stylesheet = "enquery.css")

jqueryDep <- htmltools::htmlDependency("jqueryDep", '1.12.1', src = c("href" = "jquery-ui"), script = "jquery-ui.min.js", stylesheet = "jquery-ui.min.css")

# Copy of dropNulls function for shiny to avoid using shiny:::dropNulls
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE = logical(1))]
}


