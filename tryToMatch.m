function tryToMatch()
    [shads noshads mattes masks masks_s pixels_s n_angles scales] = prepareEnv('images/2011-07-04/test/', 'png');
    
    k = 5;
    
    shad = shads{1};
    
    for sc = 1:length(scales)
        fprintf('Computing matte at scale %i...\n', scales(sc));
        if sc == 1
            prev_scales_sum = 0;
            len = scales(sc);
        else
            prev_scales_sum = sum(scales(1:sc-1));
            len = scales(sc) - prev_scales_sum;
        end
        
        mask_s = masks_s{1,sc};
        pixel_s = pixels_s{1,sc};
        
        % load training data
        data_file_path = ['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'];
        if exist(data_file_path, 'file')
            load(data_file_path);
        else
            fprintf('\tno data at this scale\n');
            continue;
        end

        recovered_matte = ones(size(shad));
        
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
                c_descrs(n) = PenumbraDescriptor(shad, pixel_s(n,:), n_angles, len, prev_scales_sum);
            end
            % current (test) spokes
            c_spokes = cat(1,c_descrs(:).spokes);
            save(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat'], 'c_descrs', 'c_spokes');
        else
            load(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat']);
        end
        
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
            % only intensity
%             spokes = spokes(:,size(spokes,2)/2:size(spokes,2));
%             c_spokes = c_spokes(:,size(c_spokes,2)/2:size(c_spokes,2));
            
        fprintf('\tfinding nearest neighbors...\n');
        if L == 1
            [best_descrs dists] = knnsearch(spokes,c_spokes,'K', k, 'NSMethod', 'kdtree');
        else
            [best_descrs dists] = knnsearch(spokes_t,c_spokes_t,'K', k, 'NSMethod', 'kdtree');
        end
        
        fprintf('\tweighting suggestions...\n');
        % turn spoke indices into descriptor indices
        best_descrs = ceil(best_descrs./(n_angles*2));
        
        best_descrs = reshape(best_descrs', n_angles*2*k, size(best_descrs,1)/(n_angles*2))';
        dists = reshape(dists', n_angles*2*k, size(dists,1)/(n_angles*2))';
        
        % turn descriptor indices into matte values
        best_mattes = center_pixels(best_descrs);

        % distance-based weights
        if max(max(dists)) == 0
            wg = 1 - dists;
%             wg = 1 / dists;
        else
            wg = repmat(max(dists, [], 2), 1, n_angles*2*k) - dists;
%             wg = 1./dists;
        end
        wg =  wg ./ repmat(sum(wg, 2), 1, n_angles*2*k);
        best_mattes = sum(best_mattes .* wg, 2);

        recovered_matte(sub2ind(size(shad), pixel_s(:,2), pixel_s(:,1))) = best_mattes;
        
%         err = mean(abs(matte(mattes{sc} < 1) - recovered_matte(mattes{sc} < 1)))
        
%         bl = 3;
%         subplot(2,3,[1 4]);
%             imshow(shad);
%         subplot(2,3,2);
%             ms = mattes{1} .* (mask_s == 1);
%             ms(ms == 0) = 1;
%             imshow(ms);
%         subplot(2,3,5);
%         imshow(imfilter(r ecovered_matte, fspecial('gaussian', bl, bl),'replicate'));
%         subplot(2,3,6);
%         imshow(shad ./ imfilter(recovered_matte, fspecial('gaussian', bl, bl),'replicate'));
%         subplot(2,3,3);
%         imshow(shad ./ ms);

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
    end
end