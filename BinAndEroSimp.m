function [imgBin, imgEro] = BinAndEroSimp(imgOrig, binThre, eroNum)
imgBin = BinaryImg(imgOrig, binThre);
imgBin = imfill(imgBin, 6, 'holes');
imgEro = ErodeImg(imgBin, 9);
for i = 1 : eroNum - 1
    imgEro = ErodeImg(imgEro, 9);
end

end

