function drawMatches()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', '_rough4');
    load('descrs_small_all.mat');
    
%     hsize = [100, 100];
%     noshad = imfilter(noshad, fspecial('gaussian', hsize, 50), 'replicate');
%     shad = noshad .* matte;
    
    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(slices_shad, build_params);
    
    k = 5;
    
%     error_gt = zeros(n_descrs, 1);
%     error_gt_img = zeros(size(shad));
%     inconsistency = zeros(n_descrs, 1);
%     inconsistency_img = zeros(size(shad));
    
    cols = ['g' 'w' 'c' 'm' 'y'];
    
    for n = 1:n_descrs
        c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);
        
        [best_descr dists] = flann_search(index,(c_descr.slices_shad)',k,parameters);
        if sum(best_descr < 1) > 0 || sum(best_descr > size(slices_shad,2)) > 0
            continue;
        end
%         
%         if best_descr(1) - n_descrs - n ~= 0
%             clc
%             c_descr.points
%             descrs(n+n_descrs).points
%         end
        
%         error_gt(n) = (descrs(best_descr(1)).center_pixel - matte(pixel(n,2), pixel(n,1)));
%         error_gt_img(c_descr.center(2), c_descr.center(1)) = error_gt(n);
%         inconsistency(n) = std(cat(1,descrs(best_descr).center_pixel));
%         inconsistency_img(c_descr.center(2), c_descr.center(1)) = inconsistency(n);
        subplot(2,2,1:2); imshow(shad); hold on; c_descr.draw('r'); %hold off;
%         subplot(2,2,2); imshow(plain); hold on; 
        for d = 1:k
            descrs(best_descr(d)).draw(cols(d));
        end
%         plot(c_descr.points(1,:,1), c_descr.points(1,:,2), 'b');
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
        s2 = descrs(best_descr(1)).slices_shad;
        s3 = improfile(matte, c_descr.points(1,:,1), c_descr.points(1,:,2));
        plot((s1), 'r'); hold on;
        plot((s2), 'g');
        plot(gradient(s3), 'b'); hold off;
%         subplot(2,2,4);
%         plot((error_gt), 'g'); hold on;
%         plot((inconsistency), 'b'); hold off;
    end
end