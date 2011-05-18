function drawMatches()
    img_date = '2011-05-03';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_shad.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_noshad.tif']);
    
    plain = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad.tif']);

    shad = shad(:,:,1);
    noshad = noshad(:,:,1);
    
    matte = shad ./ noshad;

    w = size(matte, 2);
    h = size(matte, 1);
    n_angles = 3;
    len = 100;
    n_descrs = 100;
    load('descrs_small_all.mat');
    cols = ['g' 'b' 'c' 'm' 'y' 'w'];
    
    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(slices_shad', build_params);
    
    k = 5;
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    p_pix = find(penumbra_mask == 1);   % penumbra pixels
    
    for n = 1:n_descrs
        p = getRandomImagePoint(shad);

        while penumbra_mask(p(2), p(1)) == 0
            p = getRandomImagePoint(matte);
        end

        c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);

        [best_descr dist] = matchDescrsN(c_descr, descrs, k);
            
        subplot(2,2,1); imshow(shad); hold on; c_descr.draw('r'); hold off;
        subplot(2,2,2); imshow(plain); hold on; 
            for d = 1:k
                descrs(best_descr(d)).draw(cols(d));
            end
            hold off;

%         subplot(2,2,3:4); 
%             plot(c_descr.slices_shad{1}, 'g'); hold on;
%             plot(c_descr.center_inds(1), c_descr.slices_shad{1}(c_descr.center_inds(1)), 'xr');
%             plot(descrs{best_descr}.slices_shad{1}, 'b');
%             plot(descrs{best_descr}.center_inds(1), descrs{best_descr}.slices_shad{1}(descrs{best_descr}.center_inds(1)), 'xr'); 
%             hold off;
        subplot(2,2,3:4);
            [s1 s2] = getCompatibleSlices(c_descr.slices_shad{1}, ...
                                          descrs(best_descr(1)).slices_shad{1}, ...
                                          c_descr.center_inds(1), ...
                                          descrs(best_descr(1)).center_inds(1));
          plot(gradient(s1), 'r'); hold on;
          plot(gradient(s2), 'g');
          hold off;
    end
end