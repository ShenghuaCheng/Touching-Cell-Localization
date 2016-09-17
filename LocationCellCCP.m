function cellStruct = LocationCellCCP(imgOrig, selectThre, thetaGauss, volumeThre, minR, localInd1, localInd2, localSize, localNum, xyzRes)
imgOrig = ImgResizeSpecial(imgOrig, xyzRes);
connectedComp = bwconncomp(imgOrig > 0, 6);
numObjects = connectedComp.NumObjects;
connectedCompInd = regionprops(connectedComp, 'PixelList');
cellStructructTotal = cell(numObjects, 1);
initialIndTotal = cell(numObjects, 1);
connectedCImgTotal = cell(numObjects, 1);
for i = 1 : numObjects
    tempPixelList = connectedCompInd(i).PixelList(:, [2 1 3]);
    if size(tempPixelList, 1) >= volumeThre && IsCoplanar(tempPixelList) == 0
        [initialInd, connectedCImg] = ExtractMinBox(tempPixelList, imgOrig);
        initialIndTotal{i} = initialInd;
        connectedCImgTotal{i} = connectedCImg;
    end
end
parfor i = 1 : numObjects
    tempPixelList = connectedCompInd(i).PixelList(:, [2 1 3]);
    tempcellStructruct = LocationCellCC(initialIndTotal{i}, connectedCImgTotal{i}, tempPixelList, thetaGauss, volumeThre, minR, selectThre, localInd1, localInd2, localSize, localNum);
    cellStructructTotal{i} = tempcellStructruct;
    disp(['......', num2str(i), '/', num2str(numObjects), 'with ', num2str(size(tempPixelList, 1)), ' points', '......', num2str(sum(tempcellStructruct.label == 1))]);
end
cellStruct.center = [0 0 0];
cellStruct.centerRe = [0 0 0];
cellStruct.volume = 0;
cellStruct.element{1, 1} = zeros(3, 3);
cellStruct.radius = 0;
cellStruct.label = 0;
for i = 1 : numObjects
    tempcellStruct = cellStructructTotal{i};
    t1 = size(cellStruct.center, 1);
    t2 = size(tempcellStruct.center, 1);
    cellStruct.center(t1 + 1 : t1 + t2, :) = bsxfun(@times, tempcellStruct.center, [1 1 xyzRes(1)/xyzRes(3)]);
    cellStruct.centerRe(t1 + 1 : t1 + t2, :) = bsxfun(@times, tempcellStruct.centerRe, [1 1 xyzRes(1)/xyzRes(3)]);
    cellStruct.volume(t1 + 1 : t1 + t2, 1) = tempcellStruct.volume;
    for j = 1 : t2
        cellStruct.element{t1 + j, 1} = bsxfun(@times, tempcellStruct.element{j, 1}, [1 1 xyzRes(1)/xyzRes(3)]);
    end
    cellStruct.radius(t1 + 1 : t1 + t2, 1) = tempcellStruct.radius;
    cellStruct.label(t1 + 1 : t1 + t2, 1) = tempcellStruct.label;
end
cellStruct = DeleteNearCell(cellStruct, selectThre, minR);

end

