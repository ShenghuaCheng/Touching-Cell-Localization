function [imgBin, imgEro]  = MergeBlock(dividedBlock)
tempImgBin = cell(dividedBlock.numBlock);
tempImgEro = cell(dividedBlock.numBlock);
for i = 1 : dividedBlock.numBlock(1)
    for j = 1 : dividedBlock.numBlock(2)
        for k = 1 : dividedBlock.numBlock(3)
            c1 = dividedBlock.block{i, j, k}.blockValidStartIndex;
            c2 = dividedBlock.block{i, j, k}.blockValidEndIndex;
            tempImgBin{i, j, k} = dividedBlock.imgBin{i, j, k}(c1(1) : c2(1), c1(2) : c2(2), c1(3) : c2(3));
            tempImgEro{i, j, k} = dividedBlock.imgEro{i, j, k}(c1(1) : c2(1), c1(2) : c2(2), c1(3) : c2(3));
        end
    end
end
imgBin = cell2mat(tempImgBin);
imgEro = cell2mat(tempImgEro);

end

    


           
