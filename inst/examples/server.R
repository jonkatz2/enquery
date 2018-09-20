library(shiny)
library(enquery)
options(shiny.sanitize.errors = FALSE)


function(input, output, session) {
    observeEvent(input$stop, browser())

  observeEvent(input$lower, {
    newvals <- input$lower
    newvals <- lapply(newvals, function(x) x$data)
    updateEnquerySliderInput(session, 'middle', valuelist=newvals) 
    updateEnquerySliderInput(session, 'upper', valuelist=newvals) 
  }, ignoreInit=TRUE)
  
  observeEvent(input$middle, {
    newvals <- input$middle
#    newvals <- lapply(newvals, function(x) x$data)
    updateEnquerySliderInput(session, 'upper', valuelist=newvals) 
  }, ignoreInit=TRUE)
}
