function [sizeBlock, sizeImgNew, widthOverlap] = IdentifyBlockParameter(sizeImg, numBlock, xyzRes)
if xyzRes(1) > 1.5
    widthOverlap = [12 12 12];
else
    widthOverlap = [24 24 24];
end
sizeBlock = floor((sizeImg + (numBlock - 1) .* widthOverlap) ./ numBlock);
sizeImgNew = (numBlock - 1) .* (sizeBlock - widthOverlap) + sizeBlock;

end
