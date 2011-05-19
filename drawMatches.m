function drawMatches()
    img_date = '2011-05-16';
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_shad_small50.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_noshad_small50.tif']);
    
    plain = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad_small50.tif']);
    
    shad = shad(:,:,1);
    noshad = noshad(:,:,1);

    if isa(shad, 'uint8')
        shad = double(shad)/255;
        noshad = double(noshad)/255;
    end
    
    matte = shad ./ noshad;

    w = size(matte, 2);
    h = size(matte, 1);
    n_angles = 1;
    len = 20;
    n_descrs = 100;
    load('descrs_small_all_20.mat');
    cols = ['g' 'w' 'c' 'm' 'y'];
    
    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(slices_shad', build_params);
    
    k = 2;
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    p_pix = find(penumbra_mask == 1);   % penumbra pixels
%     
%     % all pixels within penumbra
%     [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask), p_pix);
%     n_descrs = length(p_pix);
    
    % collection of n_descrs random points within penumbra
    [pixel(:,2) pixel(:,1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand(n_descrs,1)+0.5)));
    
    error_gt = zeros(n_descrs, 1);
    error_gt_img = zeros(size(shad));
    inconsistency = zeros(n_descrs, 1);
    inconsistency_img = zeros(size(shad));
    
    for n = 1:n_descrs
        c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);
        
        best_descr = flann_search(index,gradient(c_descr.slices_shad)',k,parameters);
        if sum(best_descr < 1) > 0 || sum(best_descr > size(slices_shad,1)) > 0
            continue;
        end
        
        error_gt(n) = (descrs(best_descr(1)).center_pixel - matte(pixel(n,2), pixel(n,1)));
        error_gt_img(c_descr.center(2), c_descr.center(1)) = error_gt(n);
        inconsistency(n) = std(cat(1,descrs(best_descr).center_pixel));
        inconsistency_img(c_descr.center(2), c_descr.center(1)) = inconsistency(n);
        subplot(2,2,1); imshow(shad); hold on; c_descr.draw('r'); hold off;
        subplot(2,2,2); imshow(plain); hold on; 
        for d = 1:k
            descrs(best_descr(d)).draw(cols(d));
        end
        plot(c_descr.points(1,:,1), c_descr.points(1,:,2), 'b');
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
        plot(gradient(s1), 'r'); hold on;
        plot(gradient(s2), 'g');
        plot(gradient(s3), 'b');
        hold off;
        
        subplot(2,2,4);
        plot((error_gt), 'g'); hold on;
        plot((inconsistency), 'b'); hold off;
    end
end