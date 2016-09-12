function dividedBlock = DivideImg3D(sizeBlock, numBlock, widthOverlap)
dividedBlock.sizeBlock = sizeBlock;
dividedBlock.numBlock = numBlock;
dividedBlock.widthOverlap = widthOverlap;
for i = 1 : numBlock(1)
    for j = 1 : numBlock(2)
        for k = 1 : numBlock(3)    
            tempType = DivideBlockType(i, j, k, numBlock);
            [a, b, c] = DivideBlockIndex(i, j, k);
            tempSartInd = [a * (i-1) * (sizeBlock(1) - widthOverlap(1)) + 1, b * (j-1) * (sizeBlock(2) - widthOverlap(2)) + 1, c * (k-1) * (sizeBlock(3) - widthOverlap(3)) + 1];
            tempEndInd = tempSartInd + sizeBlock -1;
            [a, b, c, d, e, f] = DivideBlockValidIndex(i, j, k, numBlock);
            tempValidSartInd = [1 + a * widthOverlap(1)/2, 1 + b * widthOverlap(2)/2, 1 + c * widthOverlap(3)/2];
            tempValidEndInd = sizeBlock - [d * widthOverlap(1)/2, e * widthOverlap(2)/2, f * widthOverlap(3)/2];
            dividedBlock.block{i, j, k} = struct('blockSerialNumber', [i j k], 'blockType', tempType, ...
                'blockStartIndex', tempSartInd, 'blockEndIndex', tempEndInd,  'blockValidStartIndex', tempValidSartInd, 'blockValidEndIndex', tempValidEndInd);
        end
    end
end
end

