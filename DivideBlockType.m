function blockType = DivideBlockType(i, j, k, numBlock)
if i*j*k == 1 || i*j*k == prod(numBlock)
    blockType = 'vertex block';
elseif i*k == 1 || i*k == numBlock(1) * numBlock(3)
    blockType = 'ridgeX block';
elseif j*k == 1 || j*k == numBlock(2) * numBlock(3)
    blockType = 'ridgeY block';
elseif i*j == 1 || i*j == numBlock(1) * numBlock(2)
    blockType = 'ridgeZ block';
elseif i == 1 || i == numBlock(1)
    blockType = 'faceXZ block';
elseif j ==1 || j == numBlock(2)
    blockType = 'faceYZ block';
elseif k ==1 || k == numBlock(3)
    blockType = 'faceXY block';
else
    blockType = 'inner block';
end

