updateEnquerySliderInput <- function(session, inputId, label = NULL, valuelist = NULL) {
  vals <- dropNulls(valuelist)
  message <- dropNulls(list(
    label = label,
    valuelist = valuelist
  ))
  invisible(session$sendInputMessage(inputId, message))
}


