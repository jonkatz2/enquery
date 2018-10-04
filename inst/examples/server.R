library(shiny)
library(enquery)
options(shiny.sanitize.errors = FALSE)

# iteratively expand the index up or down until EITHER the xtol or ytol distance is exceeded
employTol <- function(i, vx, vy, xtol, ytol, up=TRUE) {
    j <- 1
    if(up) {
        xpts <- c(vx[i], vx[i + j])
        ypts <- c(vy[i], vy[i + j])
        while(abs(xpts[2] - xpts[1]) < xtol && abs(ypts[2] - ypts[1]) < ytol) {
            j <- j + 1
            newi <- min(i + j, length(vx))
            xpts <- c(vx[i], vx[newi])
            ypts <- c(vy[i], vy[newi])
        }
    } else {
        xpts <- c(vx[i - j], vx[i])
        ypts <- c(vy[i - j], vy[i])
        while(abs(xpts[2] - xpts[1]) < xtol && abs(ypts[2] - ypts[1]) < ytol) {
            j <- j + 1
            newi <- max(i - j, 1)
            xpts <- c(vx[newi], vx[i])
            ypts <- c(vy[newi], vy[i])
        }
    }
    list(x=xpts, y=ypts)
}


function(input, output, session) {
  observeEvent(input$stop, browser())
  
  observeEvent(input$saveval, {
    saveRDS(input$myInput, 'exampleval.RDS')
  })
  observeEvent(input$setval, {
    updateDrawLineInput(session, 'myInput', valuelist = readRDS('exampleval.RDS'))
  })
  
  output$drawoutput <- renderPlot({
    dat <- input$myInput
    xlim <- c(0,25)
    xtol <- (xlim[2] - xlim[1]) * 0.01
    ylim <- c(0,50)
    ytol <- (ylim[2] - ylim[1]) * 0.01
    if(length(dat$x) > 1) {
        x <- unlist(dat$x)
        y <- unlist(dat$y)
        plot(x, y, type='l', ylim=ylim, xlim=xlim)
        xlim <- c(floor(x[1]), ceiling(x[length(x)]))
        pts <- unlist(lapply(xlim[1]:xlim[2], function(z) {
            if(z == xlim[1] && length(x) && round(x[1]) == z) {
                return(y[1])
            } else if(z == xlim[2] && length(x) && round(x[length(x)]) == z) {
                return(y[length(x)])
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
                        pts <- employTol(ind, x, y, xtol, ytol, up=FALSE)
                        xpts <- pts$x
                        ypts <- pts$y
                    } else {
                        pts <- employTol(ind, x, y, xtol, ytol)
                        xpts <- pts$x
                        ypts <- pts$y
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
  
  output$multipointCorrection <- renderTable({
    vals <- input$lower
    vals.tab <- sliderTable(vals)
    for(i in 3:6) vals.tab[i] <- as.numeric(vals.tab[,i]) 
    vals.tab$high.80 <- round(vals.tab[,'ml'] + ((vals.tab[,'high'] - vals.tab[,'ml']) * (80/vals.tab[,'confidence'])))
    vals.tab$low.80 <- round(vals.tab[,'ml'] - ((vals.tab[,'ml'] - vals.tab[,'low']) * (80/vals.tab[,'confidence'])))
    vals.tab
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
