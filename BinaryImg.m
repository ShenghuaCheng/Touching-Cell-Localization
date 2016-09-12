function imgBin = BinaryImg(imgOrig, binThre)
imgBin = zeros(size(imgOrig), 'uint8');
parfor i = 1 : size(imgOrig, 3)
    imgBackTemp = min(imgOrig(:, :, i), 100);
    imgBackTemp = padarray(imgBackTemp, [4 4], 'symmetric');
    averageTemplate = ones(9,9)/81;
    imgBackTemp = double(imgBackTemp);
    for j = 1 : 20
        imgBackTemp = conv2(imgBackTemp, averageTemplate, 'valid');
        imgBackTemp = padarray(imgBackTemp, [4 4], 'symmetric');
    end
    imgBackTemp = imgBackTemp(5 : end - 4, 5 : end - 4);
    imgBackTemp = imgBackTemp + binThre .* sqrt(imgBackTemp);
    imgBin(:, :, i) = imgOrig(:, :, i) > imgBackTemp;
end

end
