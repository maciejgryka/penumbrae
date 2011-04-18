function [p1 p2] = ensureProfileRising(im, p1, p2)
   prof = improfile(im, [p1(1) p2(1)] , [p1(2) p2(2)]);
    if prof(1) > prof(size(prof,1))
        prof = flipud(prof);
        temp = p1;
        p1 = p2;
        p2 = temp;
    end
end