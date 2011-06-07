function tryToMatch()
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16', 'rough4');

    w = size(matte, 2);
    h = size(matte, 1);
    recovered_matte = ones(h, w);
    load('descrs_small_all.mat');
    
    k = 1;

    c_descrs = repmat(PenumbraDescriptor, length(p_pix), 1);
    
    for n = 1:length(p_pix)
        c_descrs(n) = PenumbraDescriptor(shad, pixel(n,:), n_angles, len);
    end
    [best_descrs dists] = knnsearch(slices_shad,cat(1,c_descrs(:).slices_shad_cat),'K', k);

    % matte values for all test set descriptors
    nn_mattes = cat(1,descrs(best_descrs).center_pixel);

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
    recovered_matte(sub2ind(size(matte), pixel(:,2), pixel(:,1))) = weighted_matte;
    
%     recovered_matte;
    subplot(2,2,1);
    imshow(shad);
    subplot(2,2,2);
    imshow(recovered_matte);
    subplot(2,2,3);
    imshow(shad ./ recovered_matte);
    subplot(2,2,4);
    imshow(matte);
end