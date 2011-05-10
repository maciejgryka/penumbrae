function [s1 s2] = getCompatibleSlices(s1, s2, s1_cind, s2_cind)
% aligns two slices so their centers are in the same place and returns the common subset 
% s1_cind is the index of the center of slice 1
        
    % number of elements in each slice to the left and to the right of the
    % center
    s1_left_elems = s1_cind - 1;
    s1_right_elems = length(s1) - s1_cind - 1;
    
    s2_left_elems = s2_cind - 1;
    s2_right_elems = length(s2) - s2_cind - 1;

    if s1_right_elems < s2_right_elems
        s2 = s2(1:s2_cind + s1_right_elems + 1);
    elseif s1_right_elems > s2_right_elems
        s1 = s1(1:s1_cind + s2_right_elems + 1);
    end
    
    if s1_left_elems < s2_left_elems
        s2 = s2(s2_cind - s1_left_elems:length(s2));
    elseif s1_left_elems > s2_left_elems
        s1 = s1(s1_cind - s2_left_elems:length(s1));
    end
end