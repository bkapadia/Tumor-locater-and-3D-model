tumorDir = '/Users/Bhavin/Documents/MATLAB/Tumor/'
MyFiles = dir(fullfile(tumorDir, '*.png'))
mkdir ('/Users/Bhavin/Documents/MATLAB/','tumorDCM');
NewDir = '/Users/Bhavin/Documents/MATLAB/tumorDCM'; %new directory

for k=1:length(MyFiles) 
    oldFile = fullfile(tumorDir, MyFiles(k).name);
    
    
end