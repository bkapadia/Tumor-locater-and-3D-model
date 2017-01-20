cd '/Users/Bhavin/Documents/MATLAB/Tumor/'
fileFolder = fullfile('/Users/Bhavin/Documents/MATLAB/Tumor/');
dirOutput = dir(fullfile(fileFolder,'Tumor*.png'));
fileNames = {dirOutput.name};
montage(fileNames); 
imshow(montage);