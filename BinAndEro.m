function [imgBin, imgEro] = BinAndEro(imgOrig, binThre, eroThre)
denseLevel = IdentifyDenseLevel(imgOrig);
imgBin = BinaryImg(imgOrig, binThre);
imgBin = imfill(imgBin, 6, 'holes');
imgEro = ErodeImg(imgBin, 9);
connectedComp = bwconncomp(imgEro, 6);
numPoint1 = sum(imgEro(:));
numCC1 = connectedComp.NumObjects;
for i = 1 : 105
    imgEro = ErodeImg(imgEro, 9 + 0.027*i);
    connectedComp = bwconncomp(imgEro, 6);
    numPoint2 = sum(imgEro(:));
    numCC2 = connectedComp.NumObjects;
    rate1 = abs(numPoint2 - numPoint1) / numPoint1;
    rate2 = abs(numCC2 - numCC1) / numCC1;
    if denseLevel == 1
        if rate1 < eroThre && rate2 < eroThre || numPoint2 ==0 || i == 35
            break;
        end
    elseif denseLevel == 2
        if rate1 < eroThre && rate2 < eroThre && i >= 40 || numPoint2 ==0 || i == 70
            break;
        end
    else
        if rate1 < eroThre && rate2 < eroThre && i >= 75 || numPoint2 ==0 || i == 105
            break;
        end
    end
    numPoint1 = numPoint2;
    numCC1 = numCC2;
end
      
end




