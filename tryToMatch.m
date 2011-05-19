function tryToMatch()
%     % clear all
%     img_date = '2011-05-16';
%     shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_shad_small50.tif']);
%     noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough4_noshad_small50.tif']);
%   
%     shad = shad(:,:,1);
%     noshad = noshad(:,:,1);
% 
%     if isa(shad, 'uint8')
%         shad = double(shad)/255;
%         noshad = double(noshad)/255;
%     end
% 
%     matte = shad ./ noshad;
%     
%     n_angles = 1;
%     len = 20;
%     n_descrs = 2000;
%     
%     k = 1;
% 
%     [dx dy] = gradient(matte);
%     matte_abs_grad = abs(dx) + abs(dy);
%     penumbra_mask = matte_abs_grad > 0;
%     p_pix = find(penumbra_mask == 1);   % indices al all penumbra pixels   
% 
%     % all pixels within penumbra
%     [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask), p_pix);
%     n_descrs = length(p_pix);
%     
% %     % collection of n_descrs random points within penumbra
% %     [pixel(:,2) pixel(:,1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand(n_descrs,1)+0.5)));
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16');
    
    w = size(matte, 2);
    h = size(matte, 1);
    incomplete_matte = zeros(h, w);
    load('descrs_small_all_20.mat');
    
    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(slices_shad', build_params);
    
    error_gt = zeros(n_descrs, 1);
    error_gt_img = zeros(size(shad));
    
    for n = 1:n_descrs
        c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);

        best_descr = flann_search(index,gradient(c_descr.slices_shad)',k,parameters);
        if best_descr < 1 || best_descr > size(slices_shad,1)
            continue;
        end

        incomplete_matte = reconstructMatte(incomplete_matte, c_descr, descrs(best_descr));

        error_gt(n) = (descrs(best_descr(1)).center_pixel - matte(pixel(n,2), pixel(n,1)));
        error_gt_img(c_descr.center(2), c_descr.center(1)) = error_gt(n);
        
%         subplot(2,1,1); imshow(shad); hold on; c_descr.draw('r'); descrs(best_descr).draw('b'); hold off;
%         subplot(2,1,2); plot(c_descr.slices_shad(1,:), 'r'); hold on; plot(descrs(best_descr).slices_shad(1,:), 'b'); hold off;
    end
    hold off;

    matte = incomplete_matte;
    subplot(2,2,1);
    imshow(shad);
    subplot(2,2,2);
    imshow(matte);
    subplot(2,2,3);
    imshow(shad ./ matte);
    subplot(2,2,4);
    imshow(shad./noshad);
end