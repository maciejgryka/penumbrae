function tryToMatch()
    [shads noshads mattes masks masks_s pixels_s n_angles scales] = prepareEnv('images/2011-06-30/test/', 'png');
    
    k = 1;
    
    shad = shads{1};
    
    for sc = 1:length(scales)
        fprintf('Computing matte at scale %i...\n', scales(sc));
        len = scales(sc);
        mask_s = masks_s{1,sc};
        pixel_s = pixels_s{1,sc};
        
        % load training data
        if exist(['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'], 'file')
            load(['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat']);
        else
            fprintf('\tno data at this scale\n');
            continue;
        end

        recovered_matte = ones(size(shad));
%         recovered_mx = zeros(size(recovered_matte));
%         recovered_my = zeros(size(recovered_matte));
        
        if isnan(pixel_s)
            fprintf('\tno descriptors and this scale\n');
            continue;
        end

        fprintf('\tloading/calculating descriptors...\n');

        compute_c_descrs = 1;
        if compute_c_descrs
            % current (test) descriptors
            c_descrs = repmat(PenumbraDescriptor, size(pixel_s,1), 1);
            for n = 1:size(pixel_s,1)
                c_descrs(n) = PenumbraDescriptor(shad, pixel_s(n,:), n_angles, len);
            end
            % current (test) spokes
            c_spokes = cat(1,c_descrs(:).spokes);
            save(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat'], 'c_descrs', 'c_spokes');
        else
            load(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat']);
        end
        
%         % matte gradient values for descriptors in training set
%         cp_mdx = cat(1,descrs(:).center_pixel_dx);
%         cp_mdy = cat(1,descrs(:).center_pixel_dy);
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(c_spokes,1);
        c_spokes = (c_spokes - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
        fprintf('\tapplying transformation...\n');
        c_spokes_t = (L*c_spokes')';
        % cull the spokes and c_spokes matrices to include only gradient or
        % only intensity
%             % only gradient
%             spokes = spokes(:,1:size(spokes,2)/2);
%             c_spokes = c_spokes(:,1:size(c_spokes,2)/2);
%             % only intensity
%             spokes = spokes(:,size(spokes,2)/2:size(spokes,2));
%             c_spokes = c_spokes(:,size(c_spokes,2)/2:size(c_spokes,2));
        
        fprintf('\tfinding nearest neighbors...\n');
        [best_descrs dists] = knnsearch(spokes,c_spokes,'K', k, 'NSMethod', 'kdtree');
        
        fprintf('\tweighting suggestions...\n');
        % turn spoke indices into descriptor indices
        best_descrs = ceil(best_descrs./(n_angles*2));
        
        best_descrs = reshape(best_descrs', n_angles*2*k, size(best_descrs,1)/(n_angles*2))';
        dists = reshape(dists', n_angles*2*k, size(dists,1)/(n_angles*2))';
        
        % turn descriptor indices into matte values (and gradient values)
        best_mattes = center_pixels(best_descrs);
%         best_mattes_dx = cp_mdx(best_descrs);
%         best_mattes_dy = cp_mdy(best_descrs);

        % distance-based weights
        wg = (max(max(dists))-dists);
        wg =  wg ./ repmat(sum(wg, 2), 1, n_angles*2*k);
        best_mattes = sum(best_mattes .* wg, 2);
%         best_mattes_dx = sum(best_mattes_dx .* wg, 2);
%         best_mattes_dy = sum(best_mattes_dy .* wg, 2);
        
%         grad_mags_gt = sqrt(cp_mdx.^2 + cp_mdy.^2);
%         grad_angs_gt = atan(cp_mdy ./ cp_mdx);
%         show4plots(center_pixels, grad_mags_gt, center_pixels_int);
        
%         grad_mags = sqrt(best_mattes_dx.^2 + best_mattes_dy.^2);
%         grad_angs = atan(best_mattes_dy ./ best_mattes_dx);
%         show4plots(best_mattes, grad_mags, shad(sub2ind(size(shad), pixel_s(:,2), pixel_s(:,1))));

        recovered_matte(sub2ind(size(shad), pixel_s(:,2), pixel_s(:,1))) = best_mattes;
%         mattes{sc} = recovered_matte;
        
%         recovered_mx(sub2ind(size(matte), pixel_s(:,2), pixel_s(:,1))) = best_mattes_dx;
%         recovered_my(sub2ind(size(matte), pixel_s(:,2), pixel_s(:,1))) = best_mattes_dy;
        
%         err = mean(abs(matte(mattes{sc} < 1) - mattes{sc}(mattes{sc} < 1)))
        
%         subplot(2,3,[1 4]);
%             imshow(shad);
%         subplot(2,3,2);
%             ms = matte .* (mask_s == 1);
%             ms(ms == 0) = 1;
%             imshow(ms);
%         subplot(2,3,5);
%         imshow(imfilter(mattes{sc}, fspecial('gaussian', 5, 5),'replicate'));
%         subplot(2,3,6);
%         imshow(shad ./ imfilter(mattes{sc}, fspecial('gaussian', 5, 5),'replicate'));
%         subplot(2,3,3);
%         imshow(noshad);

        subplot(2,3,[1 4]);
            imshow(shad);
        subplot(2,3,2);
            ms = mattes{1} .* (mask_s == 1);
            ms(ms == 0) = 1;
            imshow(ms);
        subplot(2,3,5);
        imshow(recovered_matte);
        subplot(2,3,6);
        imshow(shad ./ recovered_matte);
        subplot(2,3,3);
        imshow(shad ./ ms);
        
%         [mdx mdy] = gradient(matte);
%         errim_int = abs(matte - mattes{sc});
%         errim_dx = abs(mdx-recovered_mx);
%         errim_dy = abs(mdy-recovered_my);
%         
% %         figure;
%         subplot(1,2,1);
%         imshow(errim_int .* mask_s);   
%         subplot(1,2,2);
%         imshow(sqrt(errim_dx.^2 + errim_dy.^2) .* mask_s);
    end
end