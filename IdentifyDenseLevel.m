function [denseLevel, temp] = IdentifyDenseLevel(img)
maxGray = double(max(prctile(img(:), 99.99), 150));
tempVar1 = double(img(:));
tempVar1 = tempVar1 / maxGray;
temp = sum(tempVar1) / numel(tempVar1) * 100;
if temp >= 0 && temp < 1
    denseLevel = 1;
elseif temp >= 1 && temp < 2
    denseLevel = 2;
elseif temp >= 2
    denseLevel = 3;
end

end


