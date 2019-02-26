# TODO: Add comment
# 
# Author: bwu
###############################################################################

###############################################################################
# Package Handling Functions
###############################################################################
# require.package function, same as require, but takes stored strings as input
require.package <- function(package) {
  eval(parse(text = gsub("x", package, "require(x)")))
}

# load.package function to require package, but install if not installed
load.package <- function(package, repos = "http://cran.us.r-project.org") {
  suppressMessages({suppressWarnings({suppressPackageStartupMessages({
    if (!require.package(package)) {
      install.packages(package, repos = repos)
    }
    require.package(package)
  })})})
}

# load.packages function, same as above, but works on array
load.packages <- function(packages, repos = "http://cran.us.r-project.org") {
  for (package in packages) load.package(package, repos)
}

###############################################################################
# Function/Input Access and Saving/Reading Data Functions
###############################################################################
# call.script function to call main R scripts
call.script <- function(name) {
  source(paste0(code.dir, name, ".R"))
}
# call.sub.script function to call sub-module R scripts
call.sub.module <- function(name) {
  source(paste0(sub.dir, name, ".R"))
}

###############################################################################
# User-Messaging Functions for Console Output
###############################################################################
# text.break function to create a line of '=' to break up text
text.break <- function() {
  message(paste(rep("=", width), collapse = ""))
}

# iso.start.msg function to alert user that new ISO is being run
section.break.msg <- function(msg) {
  
  # Output a text break before and after the message
  text.break()
  message(msg)
  text.break()
}

# header.msg function to print a header for a section of code
header.msg <- function(msg) {
  
  # Pad the message with spaces
  msg = paste0(" ", msg, " ")
  
  # Create strings of "*" to pad the message so it appears in mid window
  start = paste(rep("*", floor((width - nchar(msg)) / 2)), collapse = "")
  end = paste(rep("*", ceiling((width - nchar(msg)) / 2)), collapse = "")
  
  # Output the concatenation of the three strings
  message(paste0(start, msg, end))
}

# sub.header.msg function to print a header for a sub-section of code
sub.header.msg <- function(msg) {
  message(paste0("*** ", msg, " ***"))
}
