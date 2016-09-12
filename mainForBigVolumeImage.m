%%=====================================================================================================
%% localization of touching cells based on density-peak clustering
%  image-spilting version, suitable for big volume image stack
%  for example, an image volume 739x526x150 voxels, can be divided into 4x3x1 subblocks, subblock size is about 200x200x200 voxels 
%  note that the size of merged image may be a little less than the origal image (only few voxel)
%  input image: 8-bit TIF image stack 
%  the preprocessing parameters (binarization and erosion) are used to accurately extract the soma regions
%  the settings of preprocessing parameters had been dicussed in detail, please see 
%  "Cheng SH, Quan TW, Liu XM, Zeng Sq. Large-scale localization of touching somas from 3D images using density-peak clustering. BMC bioinformatics. 2016; doi: DOI: 10.1186/s12859-016-1252-x." 
%  the localization parameters can be easily set according to the estimated minimum and average cell radius and the xyz resolution
%  we provided test datasets and corresponding test results (the parameter setting of different datasets were provided with an excel file)
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
imgPath = 'ImageDataSet\big_data_1.tif';
xyzRes = [2 2 2]; % uint: um
isExistNeurite = 1; % if exsiting the influence of thick neurites

% output file
localizationResultPath = 'big_data_1';
localizationResultPath = ['LocalizationResults\', localizationResultPath];
mkdir(localizationResultPath);

% parameters of image preprocess
binThre = 7; % according to image contrast, 3-10
eroThre = 0.001; % set when IsExistNeurite = 1
eroNum = 5; % set when IsExistNeurite = 0, 2-8
numBlock = [2 2 2]; % dividing number in xyz axis

% parameters of localization 
minR = 1.5; % unit: voxel
averR = 4; % unit: voxel
selectThre = 1;
volumeThre = 1 * pi/6 * (2*minR)^3; % adjust the coefficient 1,
thetaGauss = 1 * averR/2 ; % unit: voxel, 

%%=====================================================================================================
%% reading image stack
%
disp('Reading image stack is begin');
imgOrig = ReadTiff(imgPath);

%%=====================================================================================================
%% processing image stack to accurately extract the soma regions with image-spilting way
%
[sizeBlock, sizeImgNew, widthOverlap] = IdentifyBlockParameter(size(imgOrig), numBlock, xyzRes);
imgOrig = imgOrig(1 : sizeImgNew(1), 1 : sizeImgNew(2), 1 : sizeImgNew(3));
sizeImg = sizeImgNew;

if sum((numBlock - 1) .* (sizeBlock - widthOverlap) + sizeBlock == sizeImg) == 3
    disp('Dividing parameter is right');
else
    disp('Dividing parameter is wrong');
end   

dividedBlock = DivideImg3D(sizeBlock, numBlock, widthOverlap);
disp('Binaring/eroding for every subblock is begin');
[w1, w2, w3] = ind2sub(numBlock, 1 : prod(numBlock));
imgOrigCell = cell(prod(numBlock), 1);
imgBinCell = cell(prod(numBlock), 1);
imgEroCell = cell(prod(numBlock), 1);
for kk = 1 : prod(numBlock)
    i = w1(kk);
    j = w2(kk);
    k = w3(kk);
    tempBlockStartIndex = dividedBlock.block{i, j, k}.blockStartIndex;
    tempBlockEndIndex = dividedBlock.block{i, j, k}.blockEndIndex;
    imgOrigCell{kk} = imgOrig(tempBlockStartIndex(1) : tempBlockEndIndex(1), tempBlockStartIndex(2) : tempBlockEndIndex(2), tempBlockStartIndex(3) : tempBlockEndIndex(3));
end
parfor kk = 1 : prod(numBlock)
    i = w1(kk);
    j = w2(kk);
    k = w3(kk);
    if isExistNeurite == 1
        [imgBinBlock, imgEroBlock] = BinAndEro(imgOrigCell{kk}, binThre, eroThre);
    else
        [imgBinBlock, imgEroBlock] = BinAndEroSimp(imgOrigCell{kk}, binThre, eroNum);
    end
    [imgBinBlock, imgEroBlock] = BinAndEro(imgOrigCell{kk}, binThre, eroNum, eroThre, isExistNeurite);
    disp(['       the [' num2str([i j k]) ']th block, binaring and eroding is completed']);
    imgBinCell{kk} = imgBinBlock;
    imgEroCell{kk} = imgEroBlock;
end
for kk = 1 : prod(numBlock)
    i = w1(kk);
    j = w2(kk);
    k = w3(kk);
    dividedBlock.imgBin{i, j, k} = imgBinCell{kk};
    dividedBlock.imgEro{i, j, k} = imgEroCell{kk};
end
clear imgOrigCell imgBinCell imgEroCell
disp('Merging the preprocessing results of all subblocks is begin');
[imgBin, imgEro] = MergeBlock(dividedBlock);
clear dividedBlock
WriteImageStack(imgOrig, [localizationResultPath, '\', 'imgOrig.tif']);
WriteImageStack(imgBin .* imgOrig, [localizationResultPath, '\', 'imgBin.tif']);
WriteImageStack(imgEro .* imgOrig, [localizationResultPath, '\', 'imgEro.tif']);

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
%GenerateExcelFile(cellStruct, xyzRes, localizationResultPath);
%matlapool close

























