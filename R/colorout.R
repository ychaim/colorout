# This file is part of colorout R package
# 
# It is distributed under the GNU General Public License.
# See the file ../LICENSE for details.
# 
# (c) 2011 Jakson Aquino: jalvesaq@gmail.com
# 
###############################################################


.onLoad <- function(libname, pkgname) {
    library.dynam("colorout", pkgname, libname, local = FALSE);

    if(is.null(getOption("colorout.anyterm")))
        options(colorout.anyterm = FALSE)
    if(is.null(getOption("colorout.emacs")))
        options(colorout.emacs = FALSE)
    if(is.null(getOption("colorout.dumb")))
        options(colorout.dumb = FALSE)
    if(is.null(getOption("colorout.verbose")))
        options(colorout.verbose = 1)

    if(testTermForColorOut() == FALSE)
        return(invisible(NULL))
    ColorOut()
}

.onUnload <- function(libpath) {
    noColorOut()
    library.dynam.unload("colorout", libpath)
}

testTermForColorOut <- function()
{
    if(getOption("colorout.anyterm"))
        return(TRUE)

    if(interactive() == FALSE)
        return(FALSE)

    termenv <- Sys.getenv("TERM")

    if(Sys.getenv("RSTUDIO") != "")
        return(FALSE)

    if(termenv != "" && termenv != "dumb")
        return(TRUE)

    if(Sys.getenv("INSIDE_EMACS") != "" && getOption("colorout.emacs") == TRUE)
        return(TRUE)

    msg <- sprintf(gettext("The R output will not be colorized because it seems that your terminal does not support ANSI escape codes.\nSys.getenv('TERM') returned '%s'.",
                           domain = "R-colorout"), termenv)
    if(termenv == ""){
        if(options("colorout.verbose") > 0)
            warning(msg, call. = FALSE, immediate. = TRUE)
        return(FALSE)
    }

    if(termenv == "dumb"){
        if(getOption("colorout.dumb"))
            return(TRUE)
        if(Sys.getenv("INSIDE_EMACS") != "")
            msg <- paste(msg,
                         gettext("Please, do ?ColorOut to know how to enable the colorizing of R output on Emacs+ESS.",
                                 domain = "R-colorout"), sep = "\n")
        if(options("colorout.verbose") > 0)
            warning(msg, call. = FALSE, immediate. = TRUE)
        return(FALSE)
    }

    return(TRUE)
}

ColorOut <- function()
{
    if(testTermForColorOut() == FALSE)
        stop(gettext("The output colorization was canceled.",
                     domain = "R-colorout"), call. = FALSE)

    .C("colorout_ColorOutput", PACKAGE="colorout")
    return (invisible(NULL))
}

noColorOut <- function()
{
    .C("colorout_noColorOutput", PACKAGE="colorout")
    return (invisible(NULL))
}

setOutputColors256 <- function(normal = 40, number = 214, negnum = 209, string = 85,
                               const = 35, stderror = 33, warn = c(1, 0, 1),
                               error = c(1, 15), verbose = TRUE)
{
    if(!is.numeric(normal))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "normal", domain = "R-colorout"))
    if(!is.numeric(number))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "number", domain = "R-colorout"))
    if(!is.numeric(negnum))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "negnum", domain = "R-colorout"))
    if(!is.numeric(string))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "string", domain = "R-colorout"))
    if(!is.numeric(const))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "const", domain = "R-colorout"))
    if(!is.numeric(stderror))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "stderror", domain = "R-colorout"))
    if(!is.numeric(error))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "error", domain = "R-colorout"))
    if(!is.numeric(warn))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "warn", domain = "R-colorout"))
    if(!is.logical(verbose))
        stop(gettextf("'verbose' must be of mode 'logical'.", domain = "R-colorout"))

    normal[normal > 255] <- 0
    normal[normal < 0] <- 0
    number[number > 255] <- 0
    number[number < 0] <- 0
    negnum[negnum > 255] <- 0
    negnum[negnum < 0] <- 0
    string[string > 255] <- 0
    string[string < 0] <- 0
    const[const > 255] <- 0
    const[const < 0] <- 0
    stderror[stderror > 255] <- 0
    stderror[stderror < 0] <- 0
    warn[warn > 255] <- 0
    warn[warn < 0] <- 0
    error[error > 255] <- 0
    error[error < 0] <- 0

    if(length(normal) < 3)
        normal <- c(rep(0, 3 - length(normal)), normal)
    if(length(number) < 3)
        number <- c(rep(0, 3 - length(number)), number)
    if(length(negnum) < 3)
        negnum <- c(rep(0, 3 - length(negnum)), negnum)
    if(length(string) < 3)
        string <- c(rep(0, 3 - length(string)), string)
    if(length(const) < 3)
        const <- c(rep(0, 3 - length(const)), const)
    if(length(stderror) < 3)
        stderror <- c(rep(0, 3 - length(stderror)), stderror)
    if(length(warn) < 3)
        warn <- c(rep(0, 3 - length(warn)), warn)
    if(length(error) < 3)
        error <- c(rep(0, 3 - length(error)), error)

    crnormal <- "\033[0"
    crnumber <- "\033[0"
    crnegnum <- "\033[0"
    crstring <- "\033[0"
    crconst  <- "\033[0"
    crstderr <- "\033[0"
    crwarn   <- "\033[0"
    crerror  <- "\033[0"

    if(normal[1])
        crnormal <- paste(crnormal, ";", normal[1], sep = "")
    if(number[1])
        crnumber <- paste(crnumber, ";", number[1], sep = "")
    if(negnum[1])
        crnegnum <- paste(crnegnum, ";", negnum[1], sep = "")
    if(string[1])
        crstring <- paste(crstring, ";", string[1], sep = "")
    if(const[1])
        crconst <- paste(crconst, ";", const[1], sep = "")
    if(stderror[1])
        crstderr <- paste(crstderr, ";", stderror[1], sep = "")
    if(warn[1])
        crwarn <- paste(crwarn, ";", warn[1], sep = "")
    if(error[1])
        crerror <- paste(crerror, ";", error[1], sep = "")

    if(normal[2])
        crnormal <- paste(crnormal, ";48;05;", normal[2], sep = "")
    if(number[2])
        crnumber <- paste(crnumber, ";48;05;", number[2], sep = "")
    if(negnum[2])
        crnegnum <- paste(crnegnum, ";48;05;", negnum[2], sep = "")
    if(string[2])
        crstring <- paste(crstring, ";48;05;", string[2], sep = "")
    if(const[2])
        crconst <- paste(crconst, ";48;05;", const[2], sep = "")
    if(stderror[2])
        crstderr <- paste(crstderr, ";48;05;", stderror[2], sep = "")
    if(warn[2])
        crwarn <- paste(crwarn, ";48;05;", warn[2], sep = "")
    if(error[2])
        crerror <- paste(crerror, ";48;05;", error[2], sep = "")

    if(normal[3])
        crnormal <- paste(crnormal, ";38;05;", normal[3], sep = "")
    if(number[3])
        crnumber <- paste(crnumber, ";38;05;", number[3], sep = "")
    if(negnum[3])
        crnegnum <- paste(crnegnum, ";38;05;", negnum[3], sep = "")
    if(string[3])
        crstring <- paste(crstring, ";38;05;", string[3], sep = "")
    if(const[3])
        crconst <- paste(crconst, ";38;05;", const[3], sep = "")
    if(stderror[3])
        crstderr <- paste(crstderr, ";38;05;", stderror[3], sep = "")
    if(warn[3])
        crwarn <- paste(crwarn, ";38;05;", warn[3], sep = "")
    if(error[3])
        crerror <- paste(crerror, ";38;05;", error[3], sep = "")

    crnormal <- paste(crnormal, "m", sep = "")
    crnumber <- paste(crnumber, "m", sep = "")
    crnegnum <- paste(crnegnum, "m", sep = "")
    crstring <- paste(crstring, "m", sep = "")
    crconst  <- paste(crconst,  "m", sep = "")
    crstderr <- paste(crstderr, "m", sep = "")
    crwarn   <- paste(crwarn,   "m", sep = "")
    crerror  <- paste(crerror,  "m", sep = "")

    .C("colorout_SetColors", crnormal, crnumber, crnegnum, crstring, crconst,
       crstderr, crwarn, crerror, as.integer(verbose), PACKAGE="colorout")

    return (invisible(NULL))
}

setOutputColors <- function(normal = 2, number = 3, negnum = 3, string = 6,
                            const = 5, stderror = 4, warn = c(1, 0, 1),
                            error = c(1, 7), verbose = TRUE)
    
{
    if(!is.numeric(normal))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "normal", domain = "R-colorout"))
    if(!is.numeric(number))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "number", domain = "R-colorout"))
    if(!is.numeric(negnum))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "negnum", domain = "R-colorout"))
    if(!is.numeric(string))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "string", domain = "R-colorout"))
    if(!is.numeric(const))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "const", domain = "R-colorout"))
    if(!is.numeric(stderror))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "stderror", domain = "R-colorout"))
    if(!is.numeric(error))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "error", domain = "R-colorout"))
    if(!is.numeric(warn))
        stop(gettextf("The value of '%s' must be a number correspoding to an ANSI escape code.", "warn", domain = "R-colorout"))
    if(!is.logical(verbose))
        stop(gettextf("'verbose' must be of mode 'logical'.", domain = "R-colorout"))

    normal[normal > 8] <- 0
    normal[normal < 0] <- 0
    number[number > 8] <- 0
    number[number < 0] <- 0
    negnum[negnum > 8] <- 0
    negnum[negnum < 0] <- 0
    string[string > 8] <- 0
    string[string < 0] <- 0
    const[const > 8] <- 0
    const[const < 0] <- 0
    stderror[stderror > 8] <- 0
    stderror[stderror < 0] <- 0
    warn[warn > 8] <- 0
    warn[warn < 0] <- 0
    error[error > 8] <- 0
    error[error < 0] <- 0

    if(length(normal) < 3)
        normal <- c(rep(0, 3 - length(normal)), normal)
    if(length(number) < 3)
        number <- c(rep(0, 3 - length(number)), number)
    if(length(negnum) < 3)
        negnum <- c(rep(0, 3 - length(negnum)), negnum)
    if(length(string) < 3)
        string <- c(rep(0, 3 - length(string)), string)
    if(length(const) < 3)
        const <- c(rep(0, 3 - length(const)), const)
    if(length(stderror) < 3)
        stderror <- c(rep(0, 3 - length(stderror)), stderror)
    if(length(warn) < 3)
        warn <- c(rep(0, 3 - length(warn)), warn)
    if(length(error) < 3)
        error <- c(rep(0, 3 - length(error)), error)

    crnormal <- "\033[0"
    crnumber <- "\033[0"
    crnegnum <- "\033[0"
    crstring <- "\033[0"
    crconst  <- "\033[0"
    crstderr <- "\033[0"
    crwarn   <- "\033[0"
    crerror  <- "\033[0"

    if(normal[1])
        crnormal <- paste(crnormal, ";", normal[1], sep = "")
    if(number[1])
        crnumber <- paste(crnumber, ";", number[1], sep = "")
    if(negnum[1])
        crnegnum <- paste(crnegnum, ";", negnum[1], sep = "")
    if(string[1])
        crstring <- paste(crstring, ";", string[1], sep = "")
    if(const[1])
        crconst <- paste(crconst, ";", const[1], sep = "")
    if(stderror[1])
        crstderr <- paste(crstderr, ";", stderror[1], sep = "")
    if(warn[1])
        crwarn <- paste(crwarn, ";", warn[1], sep = "")
    if(error[1])
        crerror <- paste(crerror, ";", error[1], sep = "")

    if(normal[2])
        crnormal <- paste(crnormal, ";4", normal[2], sep = "")
    if(number[2])
        crnumber <- paste(crnumber, ";4", number[2], sep = "")
    if(negnum[2])
        crnegnum <- paste(crnegnum, ";4", negnum[2], sep = "")
    if(string[2])
        crstring <- paste(crstring, ";4", string[2], sep = "")
    if(const[2])
        crconst <- paste(crconst, ";4", const[2], sep = "")
    if(stderror[2])
        crstderr <- paste(crstderr, ";4", stderror[2], sep = "")
    if(warn[2])
        crwarn <- paste(crwarn, ";4", warn[2], sep = "")
    if(error[2])
        crerror <- paste(crerror, ";4", error[2], sep = "")

    if(normal[3])
        crnormal <- paste(crnormal, ";3", normal[3], sep = "")
    if(number[3])
        crnumber <- paste(crnumber, ";3", number[3], sep = "")
    if(negnum[3])
        crnegnum <- paste(crnegnum, ";3", negnum[3], sep = "")
    if(string[3])
        crstring <- paste(crstring, ";3", string[3], sep = "")
    if(const[3])
        crconst <- paste(crconst, ";3", const[3], sep = "")
    if(stderror[3])
        crstderr <- paste(crstderr, ";3", stderror[3], sep = "")
    if(warn[3])
        crwarn <- paste(crwarn, ";3", warn[3], sep = "")
    if(error[3])
        crerror <- paste(crerror, ";3", error[3], sep = "")

    crnormal <- paste(crnormal, "m", sep = "")
    crnumber <- paste(crnumber, "m", sep = "")
    crnegnum <- paste(crnegnum, "m", sep = "")
    crstring <- paste(crstring, "m", sep = "")
    crconst  <- paste(crconst,  "m", sep = "")
    crstderr <- paste(crstderr, "m", sep = "")
    crwarn   <- paste(crwarn,   "m", sep = "")
    crerror  <- paste(crerror,  "m", sep = "")

    .C("colorout_SetColors", crnormal, crnumber, crnegnum, crstring, crconst,
       crstderr, crwarn, crerror, as.integer(verbose), PACKAGE="colorout")
    return(invisible(NULL))
}

show256Colors <- function(outfile = "/tmp/table256.html")
{
    c256 <- c("#000000", "#c00000", "#008000", "#804000", "#0000c0", "#c000c0",
              "#008080", "#c0c0c0", "#808080", "#ff6060", "#00ff00", "#ffff00",
              "#8080ff", "#ff40ff", "#00ffff", "#ffffff", "#000000", "#00005f",
              "#000087", "#0000af", "#0000d7", "#0000ff", "#005f00", "#005f5f",
              "#005f87", "#005faf", "#005fd7", "#005fff", "#008700", "#00875f",
              "#008787", "#0087af", "#0087d7", "#0087ff", "#00af00", "#00af5f",
              "#00af87", "#00afaf", "#00afd7", "#00afff", "#00d700", "#00d75f",
              "#00d787", "#00d7af", "#00d7d7", "#00d7ff", "#00ff00", "#00ff5f",
              "#00ff87", "#00ffaf", "#00ffd7", "#00ffff", "#5f0000", "#5f005f",
              "#5f0087", "#5f00af", "#5f00d7", "#5f00ff", "#5f5f00", "#5f5f5f",
              "#5f5f87", "#5f5faf", "#5f5fd7", "#5f5fff", "#5f8700", "#5f875f",
              "#5f8787", "#5f87af", "#5f87d7", "#5f87ff", "#5faf00", "#5faf5f",
              "#5faf87", "#5fafaf", "#5fafd7", "#5fafff", "#5fd700", "#5fd75f",
              "#5fd787", "#5fd7af", "#5fd7d7", "#5fd7ff", "#5fff00", "#5fff5f",
              "#5fff87", "#5fffaf", "#5fffd7", "#5fffff", "#870000", "#87005f",
              "#870087", "#8700af", "#8700d7", "#8700ff", "#875f00", "#875f5f",
              "#875f87", "#875faf", "#875fd7", "#875fff", "#878700", "#87875f",
              "#878787", "#8787af", "#8787d7", "#8787ff", "#87af00", "#87af5f",
              "#87af87", "#87afaf", "#87afd7", "#87afff", "#87d700", "#87d75f",
              "#87d787", "#87d7af", "#87d7d7", "#87d7ff", "#87ff00", "#87ff5f",
              "#87ff87", "#87ffaf", "#87ffd7", "#87ffff", "#af0000", "#af005f",
              "#af0087", "#af00af", "#af00d7", "#af00ff", "#af5f00", "#af5f5f",
              "#af5f87", "#af5faf", "#af5fd7", "#af5fff", "#af8700", "#af875f",
              "#af8787", "#af87af", "#af87d7", "#af87ff", "#afaf00", "#afaf5f",
              "#afaf87", "#afafaf", "#afafd7", "#afafff", "#afd700", "#afd75f",
              "#afd787", "#afd7af", "#afd7d7", "#afd7ff", "#afff00", "#afff5f",
              "#afff87", "#afffaf", "#afffd7", "#afffff", "#d70000", "#d7005f",
              "#d70087", "#d700af", "#d700d7", "#d700ff", "#d75f00", "#d75f5f",
              "#d75f87", "#d75faf", "#d75fd7", "#d75fff", "#d78700", "#d7875f",
              "#d78787", "#d787af", "#d787d7", "#d787ff", "#d7af00", "#d7af5f",
              "#d7af87", "#d7afaf", "#d7afd7", "#d7afff", "#d7d700", "#d7d75f",
              "#d7d787", "#d7d7af", "#d7d7d7", "#d7d7ff", "#d7ff00", "#d7ff5f",
              "#d7ff87", "#d7ffaf", "#d7ffd7", "#d7ffff", "#ff0000", "#ff005f",
              "#ff0087", "#ff00af", "#ff00d7", "#ff00ff", "#ff5f00", "#ff5f5f",
              "#ff5f87", "#ff5faf", "#ff5fd7", "#ff5fff", "#ff8700", "#ff875f",
              "#ff8787", "#ff87af", "#ff87d7", "#ff87ff", "#ffaf00", "#ffaf5f",
              "#ffaf87", "#ffafaf", "#ffafd7", "#ffafff", "#ffd700", "#ffd75f",
              "#ffd787", "#ffd7af", "#ffd7d7", "#ffd7ff", "#ffff00", "#ffff5f",
              "#ffff87", "#ffffaf", "#ffffd7", "#ffffff", "#080808", "#121212",
              "#1c1c1c", "#262626", "#303030", "#3a3a3a", "#444444", "#4e4e4e",
              "#585858", "#626262", "#6c6c6c", "#767676", "#808080", "#8a8a8a",
              "#949494", "#9e9e9e", "#a8a8a8", "#b2b2b2", "#bcbcbc", "#c6c6c6",
              "#d0d0d0", "#dadada", "#e4e4e4", "#eeeeee")

    sink(file = outfile)
    cat("<html>\n<head>\n  <title>256 terminal emulator colors</title>\n</head>\n")
    cat("<body bgcolor=\"#000000\">\n")
    cat("\n<p>&nbsp;</p>\n\n")
    cat("<table>\n")
    cat("<tr height=\"20\">\n  ")
    for(i in 0:7){
        cat("<td width=\"20\", title=\"", i, " ", c256[i+1],
            "\" style=\"background: ", c256[i+1], "\"></td>", sep = "")
    }
    cat("\n</tr>\n<tr height=\"20\">\n  ")
    for(i in 8:15){
        cat("<td width=\"20\", title=\"", i, " ", c256[i+1],
            "\" style=\"background: ", c256[i+1], "\"></td>", sep = "")
    }
    cat("\n</tr>\n</table>\n")
    cat("\n<p>&nbsp;</p>\n\n")
    cat("<table>\n<tr height=\"20\">\n  ")
    for(red in 0:5){
        for(green in 0:5){
            for(blue in 0:5){
                i <- 16 + (36 * red) + (6 * green) + blue
                cat("<td width=\"20\", title=\"", i, " ", c256[i+1],
                    "\" style=\"background: ", c256[i+1], "\"></td>", sep = "")
            }
            cat("<td width=\"10\"></td>\n")
            if(green < 5) cat("  ")
        }
        cat("</tr>\n")
        if(red < 5) cat("<tr height=\"20\">\n")
    }
    cat("</table>\n")
    cat("\n<p>&nbsp;</p>\n\n")
    cat("<table>\n<tr height=\"20\">\n  ")
    for(i in 232:255){
        cat("<td width=\"20\", title=\"", i, " ", c256[i+1],
            "\" style=\"background: ", c256[i+1], "\"></td>", sep = "")
    }
    cat("\n</tr>\n</table>\n</body>\n</html>")
    sink()

    browseURL(outfile)

}
