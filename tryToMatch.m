function tryToMatch()
    suffix = 'wood1';
    [shad noshad matte penumbra_mask n_angles scales] = prepareEnv('2011-06-13', suffix);

    w = size(matte, 2);
    h = size(matte, 1);
    
    k = 5;
    
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
        recovered_mx = zeros(size(recovered_matte));
        recovered_my = zeros(size(recovered_matte));
        
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

%         for n = 1:length(p_pix)
%             c_descrs(n) = PenumbraDescriptor(shad_s, pixel(n,:), n_angles, len);
%         end
%         % current (test) spokes
%         c_spokes = cat(1,c_descrs(:).spokes);
%         save(['c_descrs/c_descrs_' suffix '_' int2str(scales(sc)) '.mat'], 'c_descrs', 'c_spokes');

        load(['c_descrs/c_descrs_' suffix '_' int2str(scales(sc)) '.mat']);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(c_spokes,1);
        c_spokes = (c_spokes - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
%         drawDescr(shad_s, c_descrs);
        fprintf('\tfinding nearest neighbors...\n');
        [best_descrs dists] = knnsearch(spokes,c_spokes,'K', k);
        
        fprintf('\tweighting suggestions...\n');
        % turn spoke indices into descriptor indices
        best_descrs = ceil(best_descrs./(n_angles*2));
        
        best_descrs = reshape(best_descrs', n_angles*2*k, size(best_descrs,1)/(n_angles*2))';
        dists = reshape(dists', n_angles*2*k, size(dists,1)/(n_angles*2))';
        
        % turn descriptor indices into matte values
        best_mattes = cat(1,center_pixels(best_descrs));
        
        % distance-based weights
        wg = 1-dists;
        wg =  wg ./ repmat(sum(wg, 2), 1, n_angles*2*k);
        best_mattes = sum(best_mattes .* wg, 2);

%         % each column of the below matrix contains votes for a training-set
%         % descriptor matching a given testset descriptor
%         best_mattes = reshape(best_mattes, n_angles*2, length(best_mattes)/(n_angles*2));
%         % now average over spokes to arrive at a proposed matte value for
%         % this descriptor (might want to weight-average later)
%         best_mattes = mean(best_mattes)';
        recovered_matte(sub2ind(size(matte_s), pixel(:,2), pixel(:,1))) = best_mattes;
        mattes{sc} = recovered_matte;
        
        err = mean(abs(matte_s(mattes{sc} < 1) - mattes{sc}(mattes{sc} < 1)))
        
        errim = zeros([size(shad_s) 3]);
        errim(:,:,1) = abs(matte_s - mattes{sc});
        [rx ry] = gradient(mattes{sc});
        [mx my] = gradient(matte_s);
        errim(:,:,2) = abs(rx-mx);
        errim(:,:,3) = abs(ry-my);
        
        subplot(2,2,1);
        imshow(shad_s);
        subplot(2,2,2);
        imshow(mattes{sc});
        subplot(2,2,3);
        imshow(shad_s ./ mattes{sc});
        subplot(2,2,4);
        ms = matte_s .* (penumbra_mask_s == 1);
        ms(ms == 0) = 1;
        imshow(ms);
        
%         figure;
%         subplot(1,3,1);
%         imagesc(errim(:,:,1));
%         subplot(1,3,2);
%         imagesc(errim(:,:,2));
%         subplot(1,3,3);
%         imagesc(errim(:,:,3));
    end
end