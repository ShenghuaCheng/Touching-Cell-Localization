function cellStruct = LocationCell(img, thetaGauss, volumeThre, cellStruct, initialInd, minR, selectThre, localInd1, localInd2, localSize, localNum)
img = double(img) / 255;
imgBin = double(img > 0);
sizeImg = size(img);
numVoxel = sizeImg(1) * sizeImg(2) * sizeImg(3);
[yInd, xInd, zInd] = ind2sub(sizeImg, 1 : numVoxel);
yxzInd = [yInd; xInd; zInd];

%% compute rho (local density rho) and delta (minimum distance from points of higher density)
%
imgBin1 = imgBin(:);
delta1 = zeros(numVoxel, 1);
nearestInd1 = zeros(numVoxel, 1);
gaussTemplate3D = GenerateGaussFilter3D(thetaGauss);
tempImg = padarray(img, [round(2 * thetaGauss) round(2 * thetaGauss) round(2 * thetaGauss)], 'symmetric');
rho = convn(tempImg, gaussTemplate3D, 'valid');
rho = rho .* imgBin;
rho1 = rho(:);

[~, rhoInd] = sort(rho1, 'descend');
delta1(rhoInd(1)) = 1; 
nearestInd1(rhoInd(1)) = rhoInd(1); 
rhoIndNew = find(imgBin1(rhoInd) == 1); 
if sum(imgBin1) > localNum
    rhoPadded = padarray(rho, [(localSize - 1)/2 (localSize - 1)/2 (localSize - 1)/2]);
    ff = @(p) MinDistLocal(p, rhoInd, sizeImg, yxzInd, rhoIndNew, localInd1, localInd2, rhoPadded, localSize);
else
    ff = @(p) MinDist(p, rhoInd, sizeImg, yxzInd, rhoIndNew);
end
[ALPH, BETA] = arrayfun(ff, (2 : length(rhoIndNew)));
delta1(rhoInd(rhoIndNew(2:length(rhoIndNew)))) = ALPH;
nearestInd1(rhoInd(rhoIndNew(2:length(rhoIndNew)))) = BETA;

%% find cluster centers
%
cellInd1 = find(delta1 > 0.3 & rho1 > 0.1);
voxelInd = 1 : length(delta1);
voxelInd(delta1==0 | rho1 == 0 |delta1 > 0.3 & rho1>0.1) = [];

delta2 = delta1(voxelInd);
rho2 = rho1(voxelInd);
numGrid =1e3;
matrixGrid = zeros(ceil(max(delta2 * numGrid)) + 1, ceil(max(rho2 * numGrid)) + 1);
for i = 1 : length(delta2)
    tempVar1 = round(delta2(i) * numGrid);
    tempVar2 = round(rho2(i) * numGrid);
    matrixGrid(tempVar1 + 1, tempVar2 + 1) = matrixGrid(tempVar1 + 1, tempVar2 + 1) + 1;
end
gaussTemplate2D = fspecial('gaussian', [11 11], 3);
tempImg1 = padarray(matrixGrid, [5 5], 'symmetric');
tempRho = conv2(tempImg1/max(tempImg1(:)), gaussTemplate2D, 'valid');
rhoRhoDelta = zeros(length(delta2), 1);
for i = 1 : length(delta2)
    tempVar3 = round(delta2(i) * numGrid);
    tempVar4 = round(rho2(i) * numGrid);
    rhoRhoDelta(i) = tempRho(tempVar3 + 1, tempVar4 + 1);
end

cellInd2 = intersect(voxelInd(rhoRhoDelta < 1e-2), find(delta1 >= (selectThre * minR)/norm(sizeImg - 1)));
clusterCenter = union(cellInd2, cellInd1);
numCluster = length(clusterCenter);
tempVar5 = rho1(clusterCenter);
[~, tempVar6] = sort(tempVar5, 'descend');
removedCenter = [];
numRemoved = 0;
for i = 1 : numCluster
    for j = i + 1 : numCluster
        if norm(yxzInd(:, clusterCenter(tempVar6(i))) - yxzInd(:, clusterCenter(tempVar6(j)))) < (selectThre * minR) 
            numRemoved = numRemoved + 1;
            removedCenter(numRemoved) = clusterCenter(tempVar6(j));
        end
    end
end
clusterCenter = union(setdiff(clusterCenter, removedCenter), rhoInd(1));
numCluster = length(clusterCenter);

%% assign cluster for the points except the identified cluster centers
%
labelCluster = zeros(numVoxel, 1);
for i = 1 : numCluster
    labelCluster(clusterCenter(i)) = i;
end
iter = 0;
maxIter = 100;
while sum(labelCluster ~= 0) < sum(imgBin1) && iter < maxIter
    for i = 2 : length(rhoIndNew)
        if labelCluster(rhoInd(rhoIndNew(i))) == 0
            labelCluster(rhoInd(rhoIndNew(i))) = labelCluster(nearestInd1(rhoInd(rhoIndNew(i))));
        end
    end
    iter = iter + 1;
end

%% inversely map the coordinates in the conneceted component to the original image stack
%
tempVar7 = 1 : numVoxel;
numCell = size(cellStruct.center, 1);
cellStruct.center(numCell + 1 : numCell + numCluster, :) = bsxfun(@plus, yxzInd(:, clusterCenter)', initialInd - [1 1 1]);
for i = 1 : numCluster
    tempImg2 = logical(reshape(labelCluster == i, sizeImg));
    tempVar12 = tempVar7(tempImg2(:));
    cellStruct.volume(numCell + i, 1) = numel(tempVar12);
    tempVar8 = yxzInd(:, tempVar12)';
    cellStruct.element{numCell + i, 1} = bsxfun(@plus, tempVar8, initialInd - [1 1 1]);
    tempVar9 = mean(tempVar8, 1);
    cellStruct.centerRe(numCell + i, :) = tempVar9 + initialInd - [1 1 1];
    tempImg2 = bwperim(tempImg2);
    tempVar10 = tempVar7(tempImg2(:));
    tempVar11 = yxzInd(:, tempVar10)';
    cellStruct.radius(numCell + i, 1) = mean(sqrt(sum((bsxfun(@minus, tempVar11, tempVar9)).^2, 2))) + 0.5;
end
tempInd1 = find(cellStruct.volume(numCell + 1 : numCell + numCluster, 1) < volumeThre);
tempInd2 = find(cellStruct.volume(numCell + 1 : numCell + numCluster, 1) >= volumeThre);
cellStruct.label(numCell + tempInd1, 1) = -1;
cellStruct.label(numCell + tempInd2, 1) = 1;

end

