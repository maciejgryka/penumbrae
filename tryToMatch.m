function tryToMatch()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', '_rough1');
    
%     hsize = [100, 100];
% %     noshad = imfilter(noshad, fspecial('gaussian', hsize, 50), 'replicate');
%     noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\2011-05-16\2011-05-16_plain_noshad.tif']);
%     noshad = noshad(:,:,1);
%     noshad = noshad(150:199, 370:459);
%     shad = noshad .* matte;
    
    w = size(matte, 2);
    h = size(matte, 1);
    incomplete_matte = ones(h, w);
    load('descrs_small_all.mat');
    
    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(slices_shad, build_params);
    
    k = 5;
    
    error_gt = zeros(n_descrs, 1);
    error_gt_img = zeros(size(shad));
    
    for n = 1:n_descrs
        c_descr = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask);

        [best_descrs dists] = flann_search(index,(c_descr.slices_shad)',k,parameters);
        best_descr = best_descrs(1);
        if best_descr < 1 || best_descr > size(slices_shad,2)
            continue;
        end

        incomplete_matte = reconstructMatte(incomplete_matte, c_descr, descrs(best_descr));

        error_gt(n) = (descrs(best_descr(1)).center_pixel - matte(pixel(n,2), pixel(n,1)));
        error_gt_img(c_descr.center(2), c_descr.center(1)) = error_gt(n);
        
%         subplot(2,1,1); imshow(shad); hold on; c_descr.draw('r'); descrs(best_descr).draw('b'); hold off;
%         subplot(2,1,2); plot((c_descr.slices_shad(1,:)), 'r'); hold on; plot((descrs(best_descr).slices_shad(1,:)), 'b'); hold off;
%         matte(pixel(n,2), pixel(n,1)) - descrs(best_descr).center_pixel
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