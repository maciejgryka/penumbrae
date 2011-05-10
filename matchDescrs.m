function [best_descr min_err min_slice_err] = matchDescrs(descr, descrs)
    best_descr = 0;
    min_err = Inf;
%     min_err_pdist = Inf;
    
    for d = 1:length(descrs)
        slice_err = zeros(length(descrs{d}.slices_shad), 1);
        for s = 1:length(descrs{d}.slices_shad)
            c_slice = gradient(descr.slices_shad{s});
            db_slice = gradient(descrs{d}.slices_shad{s});
            [c_slice db_slice] = getCompatibleSlices(c_slice, db_slice, descr.center_inds(s), descrs{d}.center_inds(s));
            
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