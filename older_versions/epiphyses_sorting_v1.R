## Copyright (C) 2023 Nefeli Garoufi <nefeligar@biol.uoa.gr>


# Package installing and library loading
list.of.packages <- c("readr", "caret", "e1071", "Metrics", "dplyr")
install.packages(list.of.packages, quiet = TRUE)

suppressMessages(suppressWarnings(invisible(sapply(list.of.packages, require, 
                                                   character.only = TRUE))))

ep_sorting <- function(bone, algorithm, distance)
{
  # Setting working director
  setwd(dirname(rstudioapi::getSourceEditorContext()$path))
  
  # Data loading and prep
  data <- read.csv(file.choose(new=TRUE))
  data <- data[, c(1,8:11, 13:14,40:43, 45:46)]
  
  
  # Welcoming message
  print("Hello!")
  print(paste0("You are working with ", nrow(data), " ", bone, " bones."))
  # Functions needed
  which.mins <- function(x, mins=6) {
    head(order(x), mins)
  }
  
  
  # Dataset prep
  sample_ids <- data[,1]
  data <- data[,-1]
  
  y <- c(1,2,3,4,6,7)
  x <- c(1,2,3,4,6,7)
  
  for (i in 1:6)
  {
    colnames(data)[i] <- paste0("Y",y[i])
    colnames(data)[i+6] <- paste0("X",x[i])
  }
  
  remove(x,y)
  
  unsc_data <- data
  
  # Algorithm start
  if (algorithm == "LR")
    {
      scaleList <- readRDS(paste0("./files/scaling_coefs_", bone, ".rds"))
    
      scale_cen <- scaleList$center
      scale_sc <- scaleList$scale
      
      data[,1] <- (data[,1]-scaleList$center[1]) / scaleList$scale[1]
      data[,2] <- (data[,2]-scaleList$center[2]) / scaleList$scale[2]
      data[,3] <- (data[,3]-scaleList$center[3]) / scaleList$scale[3]
      data[,4] <- (data[,4]-scaleList$center[4]) / scaleList$scale[4]
      data[,5] <- (data[,5]-scaleList$center[5]) / scaleList$scale[5]
      data[,6] <- (data[,6]-scaleList$center[6]) / scaleList$scale[6]
      data[,7] <- (data[,7]-scaleList$center[7]) / scaleList$scale[7]
      data[,8] <- (data[,8]-scaleList$center[8]) / scaleList$scale[8]
      data[,9] <- (data[,9]-scaleList$center[9]) / scaleList$scale[9]
      data[,10] <- (data[,10]-scaleList$center[10]) / scaleList$scale[10]
      data[,11] <- (data[,11]-scaleList$center[11]) / scaleList$scale[11]
      data[,12] <- (data[,12]-scaleList$center[12]) / scaleList$scale[12]
      
      class_20 <- readRDS(paste0("./files/", bone, "_20_LR.rds")) ## model for the 20% vars
      pred_20 <- predict(class_20, newdata = data[, c(7:12)])
      pred_20[,1] <- pred_20[,1]*scaleList$scale[1] + scaleList$center[1]
      pred_20[,2] <- pred_20[,2]*scaleList$scale[2] + scaleList$center[2]
      pred_20[,3] <- pred_20[,3]*scaleList$scale[3] + scaleList$center[3]
      pred_20[,4] <- pred_20[,4]*scaleList$scale[4] + scaleList$center[4]
      pred_20[,5] <- pred_20[,5]*scaleList$scale[5] + scaleList$center[5]
      pred_20[,6] <- pred_20[,6]*scaleList$scale[6] + scaleList$center[6]
          
      class_80 <- readRDS(paste0("./files/", bone, "_80_LR.rds")) ## model for the 20% vars
      pred_80 <- predict(class_80, newdata = data[, c(1:6)])
      pred_80[,1] <- pred_80[,1]*scaleList$scale[7] + scaleList$center[7]
      pred_80[,2] <- pred_80[,2]*scaleList$scale[8] + scaleList$center[8]
      pred_80[,3] <- pred_80[,3]*scaleList$scale[9] + scaleList$center[9]
      pred_80[,4] <- pred_80[,4]*scaleList$scale[10] + scaleList$center[10]
      pred_80[,5] <- pred_80[,5]*scaleList$scale[11] + scaleList$center[11]
      pred_80[,6] <- pred_80[,6]*scaleList$scale[12] + scaleList$center[12]

          
      } else if (algorithm == "SVM") {
        
        class_20 <- readRDS(paste0("./files/", bone, "_20_SVM.rds"))
        vars <- c("Y1", "Y2", "Y3", "Y4", "Y6", "Y7")
        predY <- 0
        for (i in 1:6)
        {
          mlm1 <- class_20[[i]]
          
          pred <- predict(mlm1, newdata = data[, c(7:12)])
          predY <- cbind(predY, pred)
        }
        
        pred_20 <- predY[,-1]
        colnames(pred_20) <- vars
        
        remove(predY, vars)
        
        # Predicting the 80% variables
        class_80 <- readRDS(paste0("./files/", bone, "_80_SVM.rds"))
        vars <- c("X1", "X2", "X3", "X4", "X6", "X7")
        predY <- 0
        for (i in 1:6)
        {
          mlm2 <- class_80[[i]]
          
          pred <- predict(mlm2, newdata = data[, c(1:6)])
          predY <- cbind(predY, pred)
        }
        
        pred_80 <- predY[,-1]
        colnames(pred_80) <- vars
        
      }
  
  # Loading the thresholds
  thresholds <- read.csv(paste0("./files/",bone, "_thr_", algorithm, ".csv"))
  u_thr_20 <- as.numeric(thresholds[1,-1])
  l_thr_20 <- as.numeric(thresholds[2,-1])
  u_thr_80 <- as.numeric(thresholds[3,-1])
  l_thr_80 <- as.numeric(thresholds[4,-1])
    
  #Sorting
          
  # 20% - Minimum five
  pr_label<-0
  pr_idx <-0
  excluded <- 0
  
  plausible <- matrix(0, nrow=nrow(data), ncol=nrow(data)-5)
          
  five_pr<-matrix(0, nrow=nrow(data), ncol=6)
  #five_pr_dis_20<-matrix(0, nrow=nrow(data)+1, ncol=1)
          
  for (i in 1:nrow(data))
      {
        pr_sample <- 0
        pr_mm <- 0
        el <- 0
        mism <- 0
        fn <- 0
        
        dif_20 <- abs(sweep(unsc_data[,1:6], 2, pred_20[i,], FUN = "-"))
        
        for (k in 1:nrow(dif_20))
        {
          y_idx <-0
          #print(k)
          for (j in 1:6)
          {
            if (between(dif_20[k,j], l_thr_20[j], u_thr_20[j]))
            {
              y_idx <- y_idx + 1
            }
          }
          if (y_idx == 6)
          {
            pr_idx <- as.numeric(row.names(dif_20[k,]))
            pr_sample[k] <- sample_ids[pr_idx]
            el[k] <- k
          } else { 
            pr_idx_mm <- as.numeric(row.names(dif_20[k,]))
            pr_mm[k] <- sample_ids[pr_idx_mm]
            if (sample_ids[i] %in% pr_mm)
            {
              fn <- fn + 1
            } else{mism <- mism + 1}
          }
        }
        pr_sample <- pr_sample[!is.na(pr_sample)]
        el <- el[!is.na(el)]
        
        el_pred_20 <- pred_20[el, ]
        
        true <- unsc_data[i, 1:6]
        name <- rownames(true)
        rownames(true) <- c("true")
        
        vec <- rbind(true, el_pred_20)
        y <- as.matrix(dist(vec, method = distance, p=1.5))
            
        g <- which.mins(y[,1])
        
        excluded[i] <- mism
        
        plausible[i,] <- c(pr_sample[-g], 
                           rep(0, times=ncol(plausible)-length(pr_sample[-g])))
        
        suppressWarnings(pr_idx <- as.numeric(names(y[g,1])))
            
        if (length(five_pr[i,]) == length(sample_ids[pr_idx]))
        {
          five_pr[i,] <-sample_ids[pr_idx]
        } else {five_pr[i,] <- c(sample_ids[pr_idx], 
                                 rep(0, times=6-length(sample_ids[pr_idx])))}
        name <- c(name, rownames(y[-1,]))
        #five_pr_dis_20 <- cbind(five_pr_dis_20, name, y[,1])
            
        remove(true, vec, y)
      }
       
  stats <- c(nrow(data), sum(excluded),
             sum(excluded)/(nrow(data)*(nrow(data)-1))*100, sum(fn))
  names(stats) <- c("Sample size", "# of Excluded",
                    "TNR", "# of False Negatives")
  
  write.csv(stats, paste0("stats_20_", algorithm, "_", distance , ".csv"))
  
  five_pr<-cbind(sample_ids, five_pr)
  #five_pr_dis_20 <- five_pr_dis_20[,-1]
          
  five_pr <- five_pr[,-2]
  colnames(five_pr)<-c("Observation #", "1st Choice", "2nd Choice", 
                        "3rd Choice", "4th Choice", "5th Choice")
          
  five_pr_20 <- five_pr
  write.csv(five_pr_20, paste0("20_pred_", algorithm, "_", distance , ".csv"))
  
  plausible <- cbind(sample_ids, plausible)
  write.csv(plausible, paste0("plausible_20_", algorithm, "_", distance , ".csv"))
  
  # 80% - Minimum five
  pr_label<-0
  pr_idx <-0
  excluded <-0
  
  plausible <- matrix(0, nrow=nrow(data), ncol=nrow(data)-5)
  
  five_pr<-matrix(0, nrow=nrow(data), ncol=6)
  #five_pr_dis_80<-matrix(0, nrow=nrow(data)+1, ncol=1)
          
  for (i in 1:nrow(data))
      {
        pr_sample <- 0
        pr_mm <- 0
        el <- 0
        mism <- 0
        fn <- 0
        
        dif_80 <- abs(sweep(unsc_data[,7:12], 2, pred_80[i,], FUN = "-"))
        
        for (k in 1:nrow(dif_80))
        {
          y_idx <-0
          #print(k)
          for (j in 1:6)
          {
            if (between(dif_80[k,j], l_thr_80[j], u_thr_80[j]))
            {
              y_idx <- y_idx + 1
            }
          }
          if (y_idx == 6)
          {
            pr_idx <- as.numeric(row.names(dif_80[k,]))
            pr_sample[k] <- sample_ids[pr_idx]
            el[k] <- k
          } else { 
            pr_idx_mm <- as.numeric(row.names(dif_80[k,]))
            pr_mm[k] <- sample_ids[pr_idx_mm]
            if (sample_ids[i] %in% pr_mm)
            {
              fn <- fn + 1
            } else{mism <- mism + 1}
          }
        }
        pr_sample <- pr_sample[!is.na(pr_sample)]
        el <- el[!is.na(el)]
        
        el_pred_80 <- pred_80[el, ]
        
        true <- unsc_data[i, 7:12]
        name <- rownames(true)
        rownames(true) <- c("true")
        
        vec <- rbind(true, el_pred_80)

        y <- as.matrix(dist(vec, method = distance, p=1.5))
            
        g <- which.mins(y[,1])
        
        excluded[i] <- mism
        
        plausible[i,] <- c(pr_sample[-g], 
                           rep(0, times=ncol(plausible)-length(pr_sample[-g])))
        
        suppressWarnings(pr_idx <- as.numeric(names(y[g,1])))
            
        if (length(five_pr[i,]) == length(sample_ids[pr_idx]))
        {
          five_pr[i,] <-sample_ids[pr_idx]
        } else {five_pr[i,] <- c(sample_ids[pr_idx], 
                                 rep(0, times=6-length(sample_ids[pr_idx])))}
        name <- c(name, rownames(y[-1,]))
        #five_pr_dis_80 <- cbind(five_pr_dis_80, name, y[,1])
            
        remove(true, vec, y)
      }
  
  stats <- c(nrow(data), sum(excluded),
             sum(excluded)/(nrow(data)*(nrow(data)-1))*100, sum(fn))
  names(stats) <- c("Sample size", "# of Excluded",
                    "TNR", "# of False Negatives")
  
  write.csv(stats, paste0("stats_80", algorithm, "_", distance , ".csv"))
  
  five_pr<-cbind(sample_ids, five_pr)
  #five_pr_dis_80 <- five_pr_dis_80[,-1]
          
  five_pr <- five_pr[,-2]
  colnames(five_pr)<-c("Observation #", "1st Choice", "2nd Choice", 
                        "3rd Choice", "4th Choice", "5th Choice")
          
  five_pr_80 <- five_pr
  write.csv(five_pr_80, paste0("80_pred_", algorithm, "_", distance , ".csv"))
  
  plausible <- cbind(sample_ids, plausible)
  write.csv(plausible, paste0("plausible_80_", algorithm, "_", distance , ".csv"))
  
  # Find matches for the combination
      
  five_pr<-matrix(0, nrow=nrow(data), ncol=6)
  #five_pr_dis<-matrix(0, nrow=nrow(data)+1, ncol=1)
      
  excluded <- 0
  plausible <- matrix(0, nrow=nrow(data), ncol=nrow(data)-5)
    
  for (i in 1:nrow(data))
  {
    pr_sample <- 0
    pr_mm <- 0
    el <- 0
    mism <- 0
    fn <- 0
    #print(i)
        
    dif_20 <- abs(sweep(unsc_data[,1:6], 2, pred_20[i,], FUN = "-"))
    dif_80 <- abs(sweep(unsc_data[,7:12], 2, pred_80[i,], FUN = "-"))
    dif <- cbind(dif_20, dif_80)
    for (k in 1:nrow(dif))
      {
        y_idx <-0
        #print(k)
        for (j in 1:6)
        {
          if (between(dif_20[k,j], l_thr_20[j], u_thr_20[j]) & between(dif_80[k,j], 
                                                                         l_thr_80[j], 
                                                                         u_thr_80[j]))
          {
            y_idx <- y_idx + 1
          }
        }
        if (y_idx == 6)
        {
          pr_idx <- as.numeric(row.names(dif[k,]))
          pr_sample[k] <- sample_ids[pr_idx]
          el[k] <- k
        } else { 
          pr_idx_mm <- as.numeric(row.names(dif[k,]))
          pr_mm[k] <- sample_ids[pr_idx_mm]
          if (sample_ids[i] %in% pr_mm)
          {
            fn <- fn + 1
          } else{mism <- mism + 1}
        }
      }
      pr_sample <- pr_sample[!is.na(pr_sample)]
      el <- el[!is.na(el)]
        
      el_pred_20 <- pred_20[el, ]
      el_pred_80 <- pred_80[el, ]
        
      if (length(pr_sample) == 1 || (length(pr_sample) ==2 & pr_sample[1] == 0))
      {
        el_pred <- c(el_pred_20, el_pred_80)
      }  else {el_pred <- cbind(el_pred_20, el_pred_80)}
        
      true <- unsc_data[i, 1:12]
      name <- rownames(true)
      rownames(true) <- c("true")
        
      vec <- rbind(true, el_pred)
      y <- as.matrix(dist(vec, method = distance, p=1.5))
        
      g <- which.mins(y[,1])
        
      suppressWarnings(md_idx <- as.numeric(names(y[g,1])))
        
      excluded[i] <- mism
      if (length(sample_ids[md_idx]) > 5)
      {
        five_pr[i,] <- sample_ids[md_idx]
          
        name <- c(name, rownames(y[-1,]))
          # if (nrow(y) == nrow(five_pr_dis))
          # {
          #  five_pr_dis <- cbind(five_pr_dis, name, y[,1])
          # } else {
          #  name <- c(name, rep(NA, nrow(five_pr_dis) - length(name)))
          #  dis_1 <- c(y[,1], rep(NA, nrow(five_pr_dis) - nrow(y)))
          #  five_pr_dis <- cbind(five_pr_dis, name, dis_1)
          # }
      } else {five_pr[i,] <- c(sample_ids[md_idx], 
                                rep(0, times=6-length(sample_ids[md_idx])))}
    
    plausible[i,] <- c(pr_sample[-g], 
                          rep(0, times=ncol(plausible)-length(pr_sample[-g])))
    remove(true, vec, y, el_pred, el_pred_20, el_pred_80, g, pr_sample)
  }  
      
  five_pr<-cbind(sample_ids, five_pr)
  plausible <- cbind(sample_ids, plausible)
  #five_pr_dis <- five_pr_dis[,-1]
      
  five_pr <- five_pr[,-2]
  colnames(five_pr)<-c("Observation #", "1st Choice", "2nd Choice", 
                          "3rd Choice", "4th Choice", "5th Choice")
      
      
  write.csv(five_pr, paste0("combo_pred_", algorithm, "_", distance , ".csv"))
  
  
      
  #Definite matches
  def_m <- 0
  sorted <- c("Sample ID", "Matching")
  print("The most probable sorted pairs are:")
  for (i in 1:nrow(five_pr))
    {
      if (five_pr[i,1] %in% five_pr[i,2:6] & five_pr_80[i,1] %in% five_pr_80[i,2:6]
          & five_pr_20[i,1] %in% five_pr_20[i,2:6])
      {
        def_m <- def_m + 1
        print(paste0(c(five_pr[i,1]), " and ",
                       five_pr[i,(which(five_pr[i,1] == five_pr[i,2:6])) + 1]))
        sorted <- rbind(sorted, five_pr[i,1],
                          five_pr[i,(which(five_pr[i,1] == five_pr[i,2:6])) + 1][[1]])
      }
    }
      
  sorted <- unique(sorted)
      
  stats <- c(nrow(data), def_m, sum(excluded),
                sum(excluded)/(nrow(data)*(nrow(data)-1))*100, sum(fn))
  names(stats) <- c("Sample size", "Definite Matches", "# of Excluded",
                        "TNR", "# of False Negatives")
      
  write.csv(stats, paste0("stats_", algorithm, "_", distance , ".csv"))
  write.csv(sorted, paste0("sorted_", algorithm, "_", distance , ".csv"))
  
  
  write.csv(plausible, paste0("plausible_", algorithm, "_", distance , ".csv"))
      
  # write.csv(five_pr_dis,
  #               paste0("./Tibia/CV_LR_80/Fold_", f, "_combo_pred_dis_", meth[m], ".csv"))
  # write.csv(five_pr_dis_20,
  #               paste0("./Tibia/CV_LR_80/Fold_", f, "_20_pred_dis_", meth[m], ".csv"))
  # write.csv(five_pr_dis_80,
  #               paste0("./Tibia/CV_LR_80/Fold_", f, "_80_pred_dis_", meth[m], ".csv"))
  
}
                 