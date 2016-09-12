function GenerateSwcFile(cellStruct, xyzRes, localizationResultPath)
cellPosition = cellStruct.centerRe(cellStruct.label == 1, :);
WriteSwc(cellPosition, xyzRes, [localizationResultPath, '\', 'cellLocated.swc']);

end

