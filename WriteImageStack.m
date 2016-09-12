function WriteImageStack(img, nameImg)
n = size(img, 3);
for i = 1 : n
    imwrite(uint8(img(:, :, i)), nameImg, 'WriteMode', 'append');
end

end

