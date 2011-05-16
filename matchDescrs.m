function [best_descr min_err min_slice_err] = matchDescrs(descr, descrs)
    best_descr = 0;
    min_err = Inf;
%     min_err_pdist = Inf;
    
    for d = 1:length(descrs)
        if isnan(descrs(d).points)
            continue;
        end
        slice_err = zeros(length(descrs(d).slices_shad), 1);
        for s = 1:length(descrs(d).slices_shad)
            c_slice = gradient(descr.slices_shad{s});
            db_slice = gradient(descrs(d).slices_shad{s});
            [c_slice_c db_slice_c] = getCompatibleSlices(c_slice, db_slice, descr.center_inds(s), descrs(d).center_inds(s));
            overlap_weight = (length(c_slice_c)/length(c_slice) + length(db_slice_c)/length(db_slice))/2;
            slice_err(s) = sum((db_slice_c - c_slice_c).^2)/(overlap_weight^5);
        end
        err = mean(slice_err);

        if err < min_err
            best_descr = d;
            min_err = err;
            min_slice_err = slice_err;
        end
    end
    
    for d = 1:length(descrs)
        if isnan(descrs(d).points)
            continue
        end
        
    end
end