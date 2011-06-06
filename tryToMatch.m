function tryToMatch()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', 'rough4');

    w = size(matte, 2);
    h = size(matte, 1);
    incomplete_matte = ones(h, w);
    load('descrs_small_all.mat');
    
    k = 1;
    
    error_gt = zeros(n_descrs, 1);
    error_gt_img = zeros(size(shad));
    nn_matte_std = zeros(size(shad));

    c_descrs = repmat(PenumbraDescriptor, length(p_pix), 1);
    
    for n = 1:length(p_pix)
        c_descrs(n) = PenumbraDescriptor(shad, pixel(n,:), n_angles, len);
    end
    [best_descrs dists] = knnsearch(slices_shad,cat(1,c_descrs(:).slices_shad),'K', k);

    % matte values for all test set descriptors
    matte_vals = cat(1,descrs(:).center_pixel);
    
    % get suggested matte from each neighbor
    nn_mattes = matte_vals(best_descrs);

    % distance-based weights for each neighbor
    if k == 1
        weights = ones(size(best_descrs,1), 1);
    else
        weights = 1-dists./repmat(sum(dists,2), 1, k);
    end
    % normalize weights
    wsum = sum(weights,2);
    weights = weights./repmat(wsum, 1, k);

    % weighted average of suggested mattes
    weighted_matte = sum(nn_mattes .* weights, 2);
    incomplete_matte(sub2ind(size(matte), pixel(:,2), pixel(:,1))) = weighted_matte;
%         error_gt(n) = abs(weighted_matte - matte(pixel(n,2), pixel(n,1)));
%         error_gt_img(c_descrs(n).center(2), c_descrs(n).center(1)) = error_gt(n);
%      	nn_matte_std(c_descrs(n).center(2), c_descrs(n).center(1)) = std(nn_mattes);
%         
%         incomplete_matte = reconstructMatte(incomplete_matte, pixel(n,:), weighted_matte);
        
%         imshow(shad); hold on; c_descr.draw('r');
%         matte(pixel(n,2), pixel(n,1)) - weighted_matte
%     end
%     imagesc(error_gt_img);
%     figure; imagesc(nn_matte_std);
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