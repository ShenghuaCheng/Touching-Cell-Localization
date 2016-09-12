function imgRe = ImgResizeSpecial(img, xyzRes)
%% ��Z�����������
%
sizeImg = size(img);
sizeImgRe = round(sizeImg .* (xyzRes / xyzRes(1)));
imgRe = zeros(sizeImgRe, 'uint8');
for i = 1 : sizeImgRe(3)
    temp = min(max(round(i / (xyzRes(3) / xyzRes(1))), 1), sizeImg(3));
    imgRe(:, :, i) = img(:, :, temp);
end

end

