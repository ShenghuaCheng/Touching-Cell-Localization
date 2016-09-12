function cellStruct = DeleteNearCell(cellStruct, selectThre, minR)
temp1 = find(cellStruct.label == 1);
[~, temp2] = sort(cellStruct.volume(temp1), 'descend');
for i = 1 : numel(temp1)
    for j = i + 1 : numel(temp1)
        if norm(cellStruct.centerRe(temp1(temp2(i)), :) - cellStruct.centerRe(temp1(temp2(j)), :)) < selectThre * minR
            cellStruct.label(temp1(temp2(j)), 1) = -3;
        end
    end
end

end

