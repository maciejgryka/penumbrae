function best_descr = matchDescrs(descr, descrs)
    best_descr = 0;
    min_err = Inf;
%     min_err_pdist = Inf;
    
    for d = 1:size(descrs, 1)
        for s = 1:length(descrs{d}.slices_shad)
            c_slice = descr.slices_shad{s};
            db_slice = descrs{d}.slices_shad{s};
            if length(c_slice) > length(db_slice)
                db_slice = [db_slice; zeros(length(c_slice) - length(db_slice), 1)];
            else
                c_slice = [c_slice; zeros(length(db_slice) - length(c_slice), 1)];
            end
%             db_slice = imresize(descrs{d}.slices_shad{1}, [length(c_slice) 1]);

            err = mean((db_slice - c_slice).^2);

            if err < min_err
                best_descr = d;
                min_err = err;
%                 min_err_pdist = abs(descr.center - descrs{d}.center);
            end
        end
    end
end