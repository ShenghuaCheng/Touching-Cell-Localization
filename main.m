%%=====================================================================================================
%% localization of touching cells based on density-peak clustering
%  non-image-spilting version, suitable for small volume image stack (about less 400 x 400 x 400 voxels)
%  input image: 8-bit TIF image stack 
%  the preprocessing parameters (binarization and erosion) are used to accurately extract the soma regions
%  the settings of preprocessing parameters had been dicussed in detail, please see 
%  "Cheng SH, Quan TW, Liu XM, Zeng Sq. Large-scale localization of touching somas from 3D images using density-peak clustering. BMC bioinformatics. 2016; doi: DOI: 10.1186/s12859-016-1252-x." 
%  the localization parameters can be easily set according to the estimated minimum and average cell radius and the xyz resolution
%  we provided test datasets and corresponding test results (the parameter setting of different datasets were provided with an excel file)
%  note that data_2 and data_3 have been processed, and only need to load them, no preprocessing is needed
%  this matlab package follows MIT License
%  please cite the above paper for research use
%
clear all
clc
isOpen = matlabpool('size') >0;
if ~isOpen
    matlabpool
end
if ~(exist('LocalizationResults', 'dir') == 7)
    mkdir('LocalizationResults');
end  

%%=====================================================================================================
%% parameter settings
% image info 
imgPath = 'ImageDataSet\data_1.tif';
xyzRes = [2 2 2]; % uint: um
isExistNeurite = 1; % if exsiting the influence of thick neurites

% output file
localizationResultPath = 'data_1';
localizationResultPath = ['LocalizationResults\', localizationResultPath];
mkdir(localizationResultPath);

% parameters of image preprocess
binThre = 7; % according to image contrast, 3-10
eroThre = 0.001; % set when IsExistNeurite = 1
eroNum = 5; % set when IsExistNeurite = 0, 2-8

% parameters of localization 
minR = 1.5; % unit: voxel
averR = 4; % unit: voxel
selectThre = 1;
volumeThre = 1 * pi/6 * (2*minR)^3; % adjust the coefficient 1 
thetaGauss = 1 * averR/2 ; % unit: voxel,

%%=====================================================================================================
%% reading image stack
%
disp('Reading image stack is begin');
imgOrig = ReadTiff(imgPath);

%%=====================================================================================================
%% processing image stack to accurately extract the soma regions
%
disp('Binarization and eroding is begin');
if isExistNeurite == 1
    [imgBin, imgEro] = BinAndEro(imgOrig, binThre, eroThre);
else
    [imgBin, imgEro] = BinAndEroSimp(imgOrig, binThre, eroNum);
end
WriteImageStack(imgBin .* imgOrig, [localizationResultPath, '\', 'imgBin.tif']);
WriteImageStack(imgEro .* imgOrig, [localizationResultPath, '\', 'imgEro.tif']);
%imgEro = uint8(ReadTiff(imgPath) > 0); % data_2 and data_2 have been processed, only need to load them, no preprocessing is needed

%%=====================================================================================================
%% locaing cells
%
disp('Location on every connected component is begin');
localSize = round(averR*2) * 2 + 1;
localNum = localSize^3;
localInd1 = reshape(1 : localSize^3, [localSize, localSize, localSize]);
localInd2 = zeros(localSize, localSize, localSize);
for i = 1 : localSize
    for j = 1 : localSize
        for k = 1 : localSize
            localInd2(i, j, k) = norm([i j k] - [(localSize + 1)/2 (localSize + 1)/2 (localSize + 1)/2]);
        end
    end
end
localInd2((localSize + 1)/2, (localSize + 1)/2, (localSize + 1)/2) = 2 * localSize;

cellStruct = LocationCellCCP(imgOrig .* imgEro, selectThre, thetaGauss, volumeThre, minR, localInd1, localInd2, localSize, localNum, xyzRes);

%%=====================================================================================================
%% generating swc and and excel files of located cells
%
disp('Generaing swc and excel files is begin');
GenerateSwcFile(cellStruct, xyzRes, localizationResultPath);
GenerateExcelFile(cellStruct, xyzRes, localizationResultPath);
%matlapool close

%%=====================================================================================================
























