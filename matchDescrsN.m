function [best_descr min_err] = matchDescrsN(descr, descrs, n)
    best_descr = zeros(n,1);
    min_err = Inf*ones(n,1);
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

        [max_val max_ind] = max(min_err);
        
        if err < max_val
            best_descr(max_ind) = d;
            min_err(max_ind) = err;
        end
    end
    
    [min_err i] = sort(min_err);
    best_descr = best_descr(i);
end