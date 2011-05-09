function [best_descr min_err min_slice_err] = matchDescrs(descr, descrs)
    best_descr = 0;
    min_err = Inf;
%     min_err_pdist = Inf;
    
    for d = 1:length(descrs)
        slice_err = zeros(length(descrs{d}.slices_shad), 1);
        for s = 1:length(descrs{d}.slices_shad)
            c_slice = (descr.slices_shad{s});
            db_slice = (descrs{d}.slices_shad{s});
            [c_slice db_slice] = getCompatibleSlices(c_slice, db_slice, descr.center_inds(s), descrs{d}.center_inds(s));
%             % make slices equal length by zero-padding if neccessary
%             if length(c_slice) > length(db_slice)
%                 db_slice = [db_slice; zeros(length(c_slice) - length(db_slice), 1)];
%             else
%                 c_slice = [c_slice; zeros(length(db_slice) - length(c_slice), 1)];
%             end
            
            slice_err(s) = sum((db_slice - c_slice).^2);
        end
        err = mean(slice_err);

        if err < min_err
            best_descr = d;
            min_err = err;
            min_slice_err = slice_err;
        end
    end
end

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
%         cs1 = cs1;
    elseif s1_right_elems > s2_right_elems
        s1 = s1(1:s1_cind + s2_right_elems + 1);
%         cs2 = cs2;
    end
    
    if s1_left_elems < s2_left_elems
        s2 = s2(s2_cind - s1_left_elems:length(s2));
%         cs1 = s1;
    elseif s1_left_elems > s2_left_elems
        s1 = s1(s1_cind - s2_left_elems:length(s1));
%         cs2 = s2;
    end
end