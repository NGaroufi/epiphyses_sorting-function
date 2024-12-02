# epiphyses_sorting-function
An R function for sorting the upper and lower epiphyses utilizing cross-sectional geometric properties of 3D long bone models.

The present function allows the user to utilize a set of diaphyseal cross-sectional geometric properties of long bones (femur, tibia, and humerus), which have been previously extracted from 3D bone models using the [*csg-toolkit* GNU Octave package](https://github.com/pr0m1th3as/long-bone-diaphyseal-CSG-Toolkit/tree/v1.0.1). The only requirement for the `ep_sorting` function is the CSV file that's computed from the *csg-toolkit* containing all the measurements for every individual of the desired sample. In order to use the function, the user must first download this repository from GitHub. Then, the downloaded folder must be unzipped and the CSV data file must be copied inside the epiphyses_sorting folder. All necessary libraries are installed and loaded directly by the function.

First, the user needs to load the function in the R workspace. This is achieved with the command:
```
source("epiphyses_sorting.R")
```

A message showing the successful installation of the necessary packages will show on the R console upon loading the function. Additionally, once the function is properly loaded, it can be called from the R console as:
```
ep_sorting(bone, algorithm, distance)
```
The three inputs the `ep_sorting` requires are: 
1. bone: "femur", "tibia", or "humerus"
2. algorithm: "LR" (Linear Regression models) or "SVM" (Support Vector Machine models)
3. distance: "euclidean", "maximum", "manhattan", "canberra", or "minkowski" (the default p for minkowski is 1.5)

This will open a window of the working directory, where the user can choose the CSV file containing the measurements. The function will then display a message reporting the number of samples from the data file. The results of the analysis are saved in .csv files:
1. regarding the 5 top predictions for each sample when utilizing only the predictions from the 20% and the 80% cross-sections
2. regarding the sample statistics (sample size, definite matches, number of excluded pairs, True Negative Rate, number of false negatives)
3. regarding the sorted pairs (definite matches)
4. regarding the plausible pairs

A testing dataset for each long bone is provided as a use case. The current version utilizes the 20% and 80% cross-sections as stand-alones, which is closer to an archeological case of fragmented bones.
