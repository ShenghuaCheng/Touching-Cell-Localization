function cellStruct = LocationCellCC(initialInd, connectedCImg, tempPixelList, thetaGauss, volumeThre, minR, selectThre, localInd1, localInd2, localSize, localNum)
cellStruct.center = [0 0 0];
cellStruct.centerRe = [0 0 0];
cellStruct.volume = 0;
cellStruct.element{1, 1} = zeros(3, 3);
cellStruct.radius = 0;
cellStruct.label = 0;
if size(tempPixelList, 1) >= volumeThre && IsCoplanar(tempPixelList) == 0
    %[initialInd, connectedCImg] = ExtractMinBox(tempPixelList, imgOrig);
    cellStruct = LocationCell(connectedCImg, thetaGauss, volumeThre, cellStruct, initialInd, minR, selectThre, localInd1, localInd2, localSize, localNum);
else
    numCell = size(cellStruct.center, 1);
    cellStruct.center(numCell + 1, :) = [0 0 0];
    cellStruct.centerRe(numCell + 1, :) = [0 0 0];
    cellStruct.volume(numCell + 1, 1) = 0;
    cellStruct.element{numCell + 1, 1} = zeros(3, 3);
    cellStruct.radius(numCell + 1, 1) = 0;
    cellStruct.label(numCell + 1, 1) = -2;
end

end

