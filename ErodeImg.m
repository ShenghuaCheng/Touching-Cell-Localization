function imgEro = ErodeImg(imgBin, eroIntesity)
tempTemplate = ones(3, 3, 3, 'uint8');
tempImg = convn(padarray(imgBin, [1 1 1], 'symmetric'), tempTemplate, 'valid');
imgEro = uint8(tempImg > eroIntesity & imgBin);

end


