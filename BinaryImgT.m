function binaried_image = BinaryImgT(data)
data = uint8(data);
temp1 = size(data);
n = temp1(3);
binaried_image = zeros(temp1, 'uint8');
parfor i = 1 : n
    temp3 = graythresh(data(:, :, i));
    temp4 = min(data(:, :, i), temp3 * 255);
    temp4 = padarray(temp4, [1 1], 'symmetric');
    temp5 = ones(3,3)/9;
    temp4 = double(temp4);
    for j = 1 : 10
        temp4 = conv2(temp4, temp5, 'same');
    end
    temp4 = temp4(2 : end -1, 2 : end -1);
    temp4 = temp4 + 6 .* sqrt(temp4);
    binaried_image(:, :, i) = data(:, :, i) > temp4;     
end

end
