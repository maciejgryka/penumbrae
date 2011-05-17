function best_descr = matchDescrs(descr, slices_shad, index, params)
    best_descr = flannFind(index, descr.slices_shad', slices_shad', 1);
%     best_descr = 0;
%     min_err = Inf;
% %     min_err_pdist = Inf;
%     
%     for d = 1:length(descrs)
%         if isnan(descrs(d).points)
%             continue;
%         end
%         slice_err = zeros(size(descrs(d).slices_shad,1), 1);
%         for s = 1:size(descrs(d).slices_shad, 1)
%             c_slice = gradient(descr.getSliceShad(s));
%             db_slice = gradient(descrs(d).getSliceShad(s));
%             [c_slice_c db_slice_c] = getCompatibleSlices(c_slice, db_slice, descr.center_inds(s), descrs(d).center_inds(s));
%             overlap_weight = (length(c_slice_c)/length(c_slice) + length(db_slice_c)/length(db_slice))/2;
%             slice_err(s) = sum((db_slice_c - c_slice_c).^2)/(overlap_weight^5);
%         end
%         err = mean(slice_err);
% 
%         if err < min_err
%             best_descr = d;
%             min_err = err;
%             min_slice_err = slice_err;
%         end
%     end
%     
%     for d = 1:length(descrs)
%         if isnan(descrs(d).points)
%             continue
%         end
%         
%     end
end

function closest = flannFind(index,slice, slices_shad, index, k)
    closest = flann_search(index,slice,k,parameters);
end