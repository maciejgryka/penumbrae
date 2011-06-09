function tryToMatch()
    [shad noshad matte penumbra_mask n_angles scales] = prepareEnv('2011-05-16', 'rough4');

    w = size(matte, 2);
    h = size(matte, 1);
    
    k = 1;
    
    mattes = cell(length(scales));

    for sc = 1:length(scales)
        fprintf('Computing matte at scale %i...\n', scales(sc));
        len = scales(sc);
        
        if exist(['descrs_small_', int2str(scales(sc)), '.mat'], 'file')
            load(['descrs_small_', int2str(scales(sc)), '.mat']);
        else
            fprintf('\tno data at this scale\n');
            continue;
        end
        
        % pad the images with zero-borders
        shad_s = addBorders(shad, 1);
        matte_s = addBorders(matte, 1);
        penumbra_mask_s = addBorders(penumbra_mask, 1);
        recovered_matte = addBorders(ones(h, w), 1);
        recovered_matte = ones(size(recovered_matte));
        
        % get pixels where descriptors at given sale can be calculated
        penumbra_mask_s = getPenumbraMaskAtScale(penumbra_mask_s, scales(sc));
        p_pix = find(penumbra_mask_s' == 1);
        if (isempty(p_pix))
            fprintf('\tno descriptors and this scale\n');
            continue;
        end
        pixel = zeros(length(p_pix), 2);
        [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask_s'), p_pix);
                
        c_descrs = repmat(PenumbraDescriptor, length(p_pix), 1);

        for n = 1:length(p_pix)
            c_descrs(n) = PenumbraDescriptor(shad_s, pixel(n,:), n_angles, len);
%             imshow(shad_s);
%             hold on;
%             c_descrs(n).draw();
%             hold off;
        end
%         drawDescr(shad_s, c_descrs);
        [best_descrs dists] = knnsearch(spokes,cat(1,c_descrs(:).spokes),'K', k);

        % each column of the below matrix contains votes for a trainingset
        % descriptor matching a given testset descriptor
        best_descrs = ceil(reshape(best_descrs, n_angles*2, length(c_descrs))/(n_angles*2));
        % mode returns the most frequent element from each column
        best_descrs = mode(best_descrs)';
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
        mattes{sc} = recovered_matte;

        subplot(2,2,1);
        imshow(shad_s);
        subplot(2,2,2);
        imshow(recovered_matte);
        subplot(2,2,3);
        imshow(shad_s ./ recovered_matte);
        subplot(2,2,4);
        imshow(matte_s);
    end
end