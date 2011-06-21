function tryToMatch()
    date = '2011-06-13';
    suffix = 'rough1';
    [shad noshad matte penumbra_mask n_angles scales] = prepareEnv(date, suffix);
    
    k = 1;
    
    mattes = cell(length(scales));

    for sc = 1:length(scales)
        fprintf('Computing matte at scale %i...\n', scales(sc));
        len = scales(sc);
        
        if exist(['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'], 'file')
            load(['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat']);
        else
            fprintf('\tno data at this scale\n');
            continue;
        end

        recovered_matte = ones(size(shad));
        recovered_mx = zeros(size(recovered_matte));
        recovered_my = zeros(size(recovered_matte));
        
        % get pixels where descriptors at given sale can be calculated
        penumbra_mask_s = getPenumbraMaskAtScale(penumbra_mask, scales(sc));
        pixel = getPenumbraPixels(penumbra_mask_s);
        if isnan(pixel)
            fprintf('\tno descriptors and this scale\n');
            continue;
        end
        
        fprintf('\tloading/calculating descriptors...\n');

        % current (test) descriptors
        c_descrs = repmat(PenumbraDescriptor, size(pixel,1), 1);
        for n = 1:size(pixel,1)
            c_descrs(n) = PenumbraDescriptor(shad, pixel(n,:), n_angles, len);
        end
        % current (test) spokes
        c_spokes = cat(1,c_descrs(:).spokes);
        save(['c_descrs/c_descrs_' suffix '_' int2str(scales(sc)) '.mat'], 'c_descrs', 'c_spokes');

%         load(['c_descrs/c_descrs_' suffix '_' int2str(scales(sc)) '.mat']);
        
        % matte gradient values for descriptors in training set
        cp_mdx = cat(1,descrs(:).center_pixel_dx);
        cp_mdy = cat(1,descrs(:).center_pixel_dy);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(c_spokes,1);
        c_spokes = (c_spokes - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
%         % cull the spokes and c_spokes matrices to include only gradient or
%         % only intensity
% %             % only gradient
% %             spokes = spokes(:,1:size(spokes,2)/2);
% %             c_spokes = c_spokes(:,1:size(c_spokes,2)/2);
% %             % only intensity
% %             spokes = spokes(:,size(spokes,2)/2:size(spokes,2));
% %             c_spokes = c_spokes(:,size(c_spokes,2)/2:size(c_spokes,2));
        
        fprintf('\tfinding nearest neighbors...\n');
        [best_descrs dists] = knnsearch(spokes,c_spokes,'K', k, 'NSMethod', 'kdtree');
        
        fprintf('\tweighting suggestions...\n');
        % turn spoke indices into descriptor indices
        best_descrs = ceil(best_descrs./(n_angles*2));
        
        best_descrs = reshape(best_descrs', n_angles*2*k, size(best_descrs,1)/(n_angles*2))';
        dists = reshape(dists', n_angles*2*k, size(dists,1)/(n_angles*2))';
        
        % turn descriptor indices into matte values (and gradient values)
        best_mattes = center_pixels(best_descrs);
        best_mattes_dx = cp_mdx(best_descrs);
        best_mattes_dy = cp_mdy(best_descrs);
        
%         % for each descriptor bin the proposed values into 10 bins and
%         % extract histogram peak
%         [matte_hists xout] = hist(best_mattes, 100);
%         [c i] = max(matte_hists, [], 1);
%         best_mattes = xout(i);

        % distance-based weights
        wg = (1-dists);
        wg =  wg ./ repmat(sum(wg, 2), 1, n_angles*2*k);
        best_mattes = sum(best_mattes .* wg, 2);
        best_mattes_dx = sum(best_mattes_dx .* wg, 2);
        best_mattes_dy = sum(best_mattes_dy .* wg, 2);

        recovered_matte(sub2ind(size(matte), pixel(:,2), pixel(:,1))) = best_mattes;
        mattes{sc} = recovered_matte;
        
        recovered_mx(sub2ind(size(matte), pixel(:,2), pixel(:,1))) = best_mattes_dx;
        recovered_my(sub2ind(size(matte), pixel(:,2), pixel(:,1))) = best_mattes_dy;
        
        err = mean(abs(matte(mattes{sc} < 1) - mattes{sc}(mattes{sc} < 1)))
        
%         subplot(2,2,1);
%         imshow(shad_s);
%         subplot(2,2,2);
%         imshow(mattes{sc});
%         subplot(2,2,3);
%         imshow(shad_s ./ mattes{sc});
%         subplot(2,2,4);
%         ms = matte_s .* (penumbra_mask_s == 1);
%         ms(ms == 0) = 1;
%         imshow(ms);
        
        [mdx mdy] = gradient(matte);
        errim_int = abs(matte - mattes{sc});
        errim_dx = abs(mdx-recovered_mx);
        errim_dy = abs(mdy-recovered_my);
        
        figure;
        subplot(1,2,1);
        imshow(errim_int .* penumbra_mask_s);
        subplot(1,2,2);
        imshow(sqrt(errim_dx.^2 + errim_dy.^2) .* penumbra_mask_s);
    end
end