updateEnquerySliderInput <- function(session, inputId, label = NULL, values = NULL) {
  vals <- dropNulls(values)
  message <- dropNulls(list(
    label = label,
    values = values
  ))
  invisible(session$sendInputMessage(inputId, message))
}


