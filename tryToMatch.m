function tryToMatch()
    [shad noshad matte penumbra_mask n_angles] = prepareEnv('2011-05-16', 'rough4');

    scales = [3, 5, 10, 20, 50, 100];
    scales = [10];
    
    w = size(matte, 2);
    h = size(matte, 1);
    
    k = 1;
    
    mattes = zeros(h, w, length(scales));

    for sc = 1:length(scales)
        fprintf('Computing matte at scale %i...\n', scales(sc));
        len = scales(sc);
        
        
        load(['descrs_small_', int2str(scales(sc)), '.mat']);
    
        % get pixels where descriptors at given sale can be calculated
        penumbra_mask_s = getPenumbraMaskAtScale(penumbra_mask, sc);
        
        % pad the images with zero-borders of width len
        shad_s = addZeroBorders(shad, len);
        noshad_s = addZeroBorders(noshad, len);
        matte_s = addZeroBorders(matte, len);
        penumbra_mask_s = addZeroBorders(penumbra_mask_s, len);
        recovered_matte = addZeroBorders(ones(h, w), len);
        recovered_matte = ones(size(recovered_matte));
        
        p_pix = find(penumbra_mask_s' == 1);
        pixel = zeros(length(p_pix), 2);
        [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask_s'), p_pix);
                
        c_descrs = repmat(PenumbraDescriptor, length(p_pix), 1);

        for n = 1:length(p_pix)
            c_descrs(n) = PenumbraDescriptor(shad_s, pixel(n,:), n_angles, len);
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
        recovered_matte(sub2ind(size(matte_s), pixel(:,2), pixel(:,1))) = weighted_matte;

        mattes(:,:,sc) = recovered_matte;
    %     recovered_matte;
%         subplot(2,2,1);
%         imshow(shad_s);
%         subplot(2,2,2);
%         imshow(recovered_matte);
%         subplot(2,2,3);
%         imshow(shad_s ./ recovered_matte);
%         subplot(2,2,4);
%         imshow(matte_s);
    end
end