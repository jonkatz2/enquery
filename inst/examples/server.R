library(shiny)
library(enquery)
options(shiny.sanitize.errors = FALSE)


function(input, output, session) {
  observeEvent(input$stop, browser())

  observeEvent(input$setval, {
    updateDrawLineInput(session, 'myInput', valuelist = readRDS('exampleval.RDS'))
  })
  
  output$drawoutput <- renderPlot({
    dat <- input$myInput
    if(length(dat$x)) {
        x <- unlist(dat$x)
        y <- unlist(dat$y)
        plot(x, y, type='l', ylim=c(0,100), xlim=c(0,25))
#        browser()
        pts <- unlist(lapply(1:25, function(z) {
            nearx <- abs(z-x)
            if(min(nearx)[1] < 0.0001) return(y[which(nearx == min(nearx))])
            else {
                ind <- which(nearx == min(nearx[nearx > 0])[1])[1]
                return(mean(c(y[ind - 1], y[ind + 1])))
            }
        }))
        ln <- lapply(pts, function(z) c(0, z))
        for(i in 1:25) lines(x=c(i,i), y=ln[[i]], col='gray')
        points(x=1:25, y=pts, pch=19)
        legend('topleft', legend=c('as drawn', 'interpolated'), lty=c(1, NA), pch=c(NA, 19), bty='n')
    } else NULL
  })

  observeEvent(input$lower, {
    newvals <- input$lower
    newvals <- lapply(newvals, function(x) x$data)
    updateMultiPointSliderInput(session, 'middle', valuelist=newvals) 
    updateMultiPointSliderInput(session, 'upper', valuelist=newvals) 
  }, ignoreInit=TRUE)
  
  observeEvent(input$middle, {
    newvals <- input$middle
#    newvals <- lapply(newvals, function(x) x$data)
    updateMultiPointSliderInput(session, 'upper', valuelist=newvals) 
  }, ignoreInit=TRUE)
}
