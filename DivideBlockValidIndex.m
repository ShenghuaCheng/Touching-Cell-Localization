function [a, b, c, d, e, f] = DivideBlockValidIndex(i, j, k, numBlock)
a = i ~= 1;
b = j ~= 1;
c = k ~= 1;
d = i ~= numBlock(1);
e = j ~= numBlock(2);
f = k ~= numBlock(3);
end

