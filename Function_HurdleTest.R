###################################################################################################
# CESI project-Hurdle Test
# This part of the code provides a function that calculates the trend of a set of data based
# on Hurdle Test.
###################################################################################################

  hurdle.test <- function(v){
    # Are we confident there is a trend?
    # Count portion of hurdle
    data.c <- data.p[data.p[[v]]>0,]
    model.count <- tryCatch(MASS::glm.nb(data.c[[v]]~data.c$year),
                            error=function(e){return("A")})
    low.c<- ifelse(is.character(model.count), NA, exp(confint(model.count, level=0.9))[2,1])
    hi.c <- ifelse(is.character(model.count), NA, exp(confint(model.count, level=0.9))[2,2])
    # Zero portion of hurdle
    data.p$z <- !I(data.p[[v]]==0)
    model.zero <- tryCatch(glm(z~year, data.p, family = "binomial"),
                           error=function(e){return("A")})
    low.z<-ifelse(is.character(model.zero), NA, exp(confint(model.zero, level=0.9))[2,1])
    hi.z<-ifelse(is.character(model.zero), NA, exp(confint(model.zero, level=0.9))[2,2])
    
    if(!is.na(low.c)&!is.na(hi.c)&!is.na(low.z)&!is.na(hi.z)){
    # combined confidence test @ 70% and 90% confidence
      pass <<- ifelse(all(low.c*low.z<=1, hi.c*hi.z>=1), "Maybe?", "Confident")
      if (pass == "Maybe?"){
        low.c<- exp(confint(model.count, level=0.7))[2,1]
        hi.c <- exp(confint(model.count, level=0.7))[2,2]
        low.z<-exp(confint(model.zero, level=0.7))[2,1]
        hi.z<-exp(confint(model.zero, level=0.7))[2,2]
        pass <<- ifelse(all(low.c*low.z<=1, hi.c*hi.z>=1), "Uncertain", "Likely")
      }
      
      # Get slope and intercept from hurdle
      model <- hurdle(data.p[[v]]~data.p$year, dist="negbin", zero.dist = "binomial", link = "logit")
      # fitted <- unname(model$fitted.values)
      assign("fitted", unname(model$fitted.values), envir = globalenv())
      slope <<- round((fitted[length(fitted)] - fitted[1])/
                        (max(data.p$year) - min(data.p$year)),2)
      intercept <<- round((fitted[1]-min(data.p$year)*((fitted[length(fitted)] - fitted[1])/
                                                         (max(data.p$year) - min(data.p$year)))),2)
      years.for.trend <<- sum(!is.na(data.p[[v]]))
      test <<- "hurdle"
    }else{
      pass <<- NA
    }  
  }