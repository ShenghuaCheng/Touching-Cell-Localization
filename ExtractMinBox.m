function [initialInd, connectedCImg] = ExtractMinBox(pixelList, imgOrig)
temp2 = min(pixelList, [], 1);
temp3 = max(pixelList, [], 1);
temp7 =  sub2ind([temp3(1) - temp2(1) + 1, temp3(2) - temp2(2) + 1, temp3(3) - temp2(3) + 1], pixelList(:, 1) - temp2(1) + 1, pixelList(:, 2) - temp2(2) + 1, pixelList(:, 3) - temp2(3) + 1);
temp4 = imgOrig(temp2(1) : temp3(1), temp2(2) : temp3(2), temp2(3) : temp3(3));
temp4_1 = temp4;
temp4 = zeros(size(temp4), 'uint8');
temp4(temp7) = temp4_1(temp7);
initialInd = temp2;
connectedCImg = temp4;


