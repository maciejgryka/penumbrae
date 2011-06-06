function drawMatches()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', 'rough4');
    load('descrs_small_all.mat');
    
    k = 5;
    
%     error_gt = zeros(n_descrs, 1);
%     error_gt_img = zeros(size(shad));
%     inconsistency = zeros(n_descrs, 1);
%     inconsistency_img = zeros(size(shad));
    
    cols = ['g' 'w' 'c' 'm' 'y'];
    
    for n = 1:n_descrs
        c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);
        
        [best_descrs dists] = knnsearch(slices_shad,cat(1,c_descr.slices_shad),'K', k);

        subplot(2,2,1:2); imshow(shad); hold on; c_descr.draw('r');

        for d = 1:k
            descrs(best_descrs(d)).draw(cols(d));
        end
        hold off;

%         subplot(2,2,3:4); 
%             plot(c_descr.slices_shad{1}, 'g'); hold on;
%             plot(c_descr.center_inds(1), c_descr.slices_shad{1}(c_descr.center_inds(1)), 'xr');
%             plot(descrs{best_descr}.slices_shad{1}, 'b');
%             plot(descrs{best_descr}.center_inds(1), descrs{best_descr}.slices_shad{1}(descrs{best_descr}.center_inds(1)), 'xr'); 
%             hold off;
        subplot(2,2,3);
%         [s1 s2] = getCompatibleSlices(c_descr.slices_shad{1}, ...
%                                       descrs(best_descr(1)).slices_shad{1}, ...
%                                       c_descr.center_inds(1), ...
%                                       descrs(best_descr(1)).center_inds(1));
        s1 = c_descr.slices_shad;
        s2 = descrs(best_descrs(1)).slices_shad;
        s3 = improfile(matte, c_descr.points(1,:,1), c_descr.points(1,:,2));
        plot((s1), 'r'); hold on;
        plot((s2), 'g');
        plot(gradient(s3), 'b'); hold off;
%         subplot(2,2,4);
%         plot((error_gt), 'g'); hold on;
%         plot((inconsistency), 'b'); hold off;
    end
end