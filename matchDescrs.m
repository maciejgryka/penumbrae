function [best_descr min_err min_slice_err] = matchDescrs(descr, descrs)
    best_descr = 0;
    min_err = Inf;
%     min_err_pdist = Inf;
    
    for d = 1:length(descrs)
        slice_err = zeros(length(descrs{d}.slices_shad), 1);
        for s = 1:length(descrs{d}.slices_shad)
            c_slice = gradient(descr.slices_shad{s});
            db_slice = gradient(descrs{d}.slices_shad{s});
            % make slices equal length by zero-padding if neccessary
            if length(c_slice) > length(db_slice)
                db_slice = [db_slice; zeros(length(c_slice) - length(db_slice), 1)];
            else
                c_slice = [c_slice; zeros(length(db_slice) - length(c_slice), 1)];
            end
            
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