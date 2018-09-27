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
    xlim <- c(0,25)
    ylim <- c(0,50)
    if(length(dat$x) > 1) {
        x <- unlist(dat$x)
        y <- unlist(dat$y)
        plot(x, y, type='l', ylim=ylim, xlim=xlim)
        pts <- unlist(lapply(xlim[1]:xlim[2], function(z) {
            if(z == xlim[1] && length(x) && round(x[1]) == z) {
                return(y[1])
            } else if(z == xlim[2] && length(x) && round(x[length(x)]) == z) {
                xpts <- c(x[length(x)-1], x[length(x)])
                ypts <- c(y[length(x)-1], y[length(x)])
                if(xpts[1] == xpts[2]) return(mean(ypts))
                else {
                    ff <- stats::approxfun(x=xpts, y=ypts)
                    ff(z)
                }
            } else {
                nearx <- abs(z-x)
                if(min(nearx)[1] < 0.0001) return(y[which(nearx == min(nearx))][1])
                else {
                    ind <- which(nearx == min(nearx))[1]
                    if(ind == 1) {
                        xpts <- c(x[ind], x[ind + 1])
                        ypts <- c(y[ind], y[ind + 1])
                    } else if(ind == length(x)) {
                        xpts <- c(x[ind - 1], x[ind])
                        ypts <- c(y[ind - 1], y[ind])
                    } else if(x[ind] > z && x[ind - 1] < z) {
                        xpts <- c(x[ind - 1], x[ind])
                        ypts <- c(y[ind - 1], y[ind])
                    } else {
                        xpts <- c(x[ind], x[ind + 1])
                        ypts <- c(y[ind], y[ind + 1])
                    }
                    if(xpts[1] == xpts[2]) return(mean(ypts))
                    else {
                        ff <- stats::approxfun(x=xpts, y=ypts)
                        ff(z)
                    }
                }
            }
        }))
        ln <- lapply(pts, function(z) c(0, z))
        xes <- xlim[1]:xlim[2]
        for(i in 1:length(ln)) lines(x=xes[c(i, i)], y=ln[[i]], col='gray')
        points(x=xlim[1]:xlim[2], y=pts, pch=19)
        legend('topleft', legend=c('as drawn', 'interpolated'), lty=c(1, NA), pch=c(NA, 19), bty='n')
    } else {
        x <- y <- 1
        plot(x, y, type='n', ylim=ylim, xlim=xlim)
        legend('topleft', legend=c('as drawn', 'interpolated'), lty=c(1, NA), pch=c(NA, 19), bty='n')
    }
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
