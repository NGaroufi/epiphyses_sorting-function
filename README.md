# epiphyses_sorting-function
An R function for sorting the upper and lower epiphyses utilizing cross-sectional geometric properties of 3D long bone models.

The present function allows the user to utilize a set of diaphyseal cross-sectional geometric properties of long bones (femur, tibia, and humerus), which have been previously extracted from 3D bone models using the [*csg-toolkit* GNU Octave package](https://github.com/pr0m1th3as/long-bone-diaphyseal-CSG-Toolkit/tree/v1.0.1). The only requirement for the `ep_sorting` function is the CSV file that's computed from the *csg-toolkit* containing all the measurements for every individual of the desired sample. In order to use the function, the user must first download this repository from GitHub. Then, the downloaded folder must be unzipped and the CSV data file must be copied inside the epiphyses_sorting folder. All necessary libraries are installed and loaded directly by the function.

The function can be used either from the `app.R` file available upon download or from the command line of an R programming environment. 

## `app.R` file: 
Upon opening the file with in an R programming environment, the user only needs to choose `Run App` to run the Shiny application. A GUI window will open, allowing the user to choose the type of bone, distance, and threshold value needed for their study, as well as whther the software is being used for a validation study (i.e. when the user knows the ground truth) or as an application on an unknown dataset. Upon clicking on the `Choose your data file(s)` button, a second window (or two, in case of an unknown dataset) will pop up and the user can then choose the relevant dataset. The results of the most probable pairs will appear on the screen, while more detailed results will be saved as `.csv` files on the working directory.

<img align="center" width="400" height="150" src="https://github.com/user-attachments/assets/6e28d3d0-ae53-474e-8d11-d4ff54bfd7fa">

## Console:
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
2. distance: "euclidean", "maximum", "manhattan", "canberra", or "minkowski" (the default p for minkowski is 1.5)
3. threshold_value: "1", "125" (=1.25), "15" (=1.5), "175" (=1.75), "2"
4. ground_truth: "TRUE" in case of a validation study (one dataset), "FALSE" in case of an unknown dataset (two files)

This will open a window of the working directory, where the user can choose the CSV file containing the measurements. The function will then display a message reporting the number of samples from the data file. The results of the analysis are saved in .csv files:
1. regarding the 5 top predictions for each sample when utilizing only the predictions from the 20% and the 80% cross-sections
2. regarding the sample statistics (sample size, definite matches, number of excluded pairs, True Negative Rate, number of false negatives)
3. regarding the sorted pairs (definite matches)
4. regarding the plausible pairs

A testing dataset for each long bone is provided as a use case. The current version utilizes the 20% and 80% cross-sections as stand-alones, which is closer to an archeological case of fragmented bones. Testing datasets for a case of an unknown sample (i.e. two datasets - one for the 20% cross-sections and one for the 80% variables) are also provided as an example for the femur bone.
