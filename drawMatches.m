function drawMatches()
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

        if isnan(pixel_s)
            fprintf('\tno descriptors and this scale\n');
            continue;
        end

        fprintf('\tloadingdescriptors...\n');
        if exist(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat'], 'file')
            load(['c_descrs/c_descrs_' 'test' '_' int2str(scales(sc)) '.mat']);
        else
            error('File not found.');
        end
        
        fprintf('\tnormalizing...\n');
        n_spokes = size(c_spokes_all,1);
        c_spokes_all = (c_spokes_all - repmat(spokes_mu, n_spokes, 1))./repmat(spokes_std, n_spokes, 1);
        
        c_spokes = cell(2*n_angles, 1);
        for sa = 1:2*n_angles
            c_spokes{sa} = c_spokes_all(sa:2*n_angles:length(c_spokes_all), :);
        end
        
%         fprintf('\tapplying transformation...\n');
%         c_spokes_all_t = (L*c_spokes_all')';
        
%         % choosing dimensionality
%         % cull the spokes and c_spokes_all matrices to include only gradient or
%         % only intensity
%             % only gradient
%             spokes = spokes(:,1:size(spokes,2)/2);
%             c_spokes_all = c_spokes_all(:,1:size(c_spokes_all,2)/2);
%             % only intensity
%             spokes = spokes(:,size(spokes,2)/2:size(spokes,2));
%             c_spokes_all = c_spokes_all(:,size(c_spokes_all,2)/2:size(c_spokes_all,2));
            
        fprintf('\tfinding nearest neighbors...\n');
        best_descrs = cell(2*n_angles, 1);
        recovered_matte = ones(100, 100, 2*n_angles);
        for sp = 1:2*n_angles
            best_descrs{sp} = knnsearch(spokes{sp},c_spokes{sp},'K', k, 'NSMethod', 'kdtree');
            best_descrs{sp} = getBestDescrs(best_descrs{sp}, descrs_vectors(best_descrs{sp}, :), c_spokes_all, k);
            
            rm = recovered_matte(:,:,sp);
            rm(sub2ind(size(shad), pixel_s(:,2), pixel_s(:,1))) = cat(1, descrs(best_descrs{sp}).center_pixel);
            recovered_matte(:,:,sp) = rm;
        end
        
        mean_matte = mean(recovered_matte, 3);

        fprintf('\tclick on shadow image\n');
        while 1
            [pix(1) pix(2)] = ginput(1);
            pix = floor(pix);

            matte_gt = mattes{1} .* (mask_s == 1);
            matte_gt(matte_gt == 0) = 1;
            drawMattesAndDesc(shad, matte_gt, mean_matte, pix, n_angles, len, prev_scales_sum);
        end
    end
end

function drawMattesAndDesc(shad, matte_gt, matte, pix, n_angles, len, prev_scales_sum)
    si = 1; % spoke index
    subplot(2,3,[1 4]);
        imshow(shad);
        d = PenumbraDescriptor(shad, pix, n_angles, len, prev_scales_sum);
        hold on;
        d.draw();
        hold off;
    subplot(2,3,2);
        d = PenumbraDescriptor(shad, pix, n_angles, len, prev_scales_sum);
        plot(d.spokes(si, :), 'k');
        hold on;
        d = PenumbraDescriptor(matte_gt, pix, n_angles, len, prev_scales_sum);
        plot(d.spokes(si, :), 'r');
        hold off;
    subplot(2,3,5);
        d = PenumbraDescriptor(shad, pix, n_angles, len, prev_scales_sum);
        plot(d.spokes(si, :), 'k');
        hold on;
        d = PenumbraDescriptor(matte, pix, n_angles, len, prev_scales_sum);
        plot(d.spokes(si, :), 'r');
        hold off;
    subplot(2,3,6);
        grayOnGreen(matte);
    subplot(2,3,3);
        grayOnGreen(matte_gt);
end

function best_descrs = getBestDescrs(best_descrs, descrs_vectors, c_spokes_all, k)
    c_descr_vectors = reshape(c_spokes_all', size(descrs_vectors, 2), [])';

    cdvi = repmat(1:size(c_descr_vectors,1), k, 1); % c_descr_vector indices
    c_descr_vectors = c_descr_vectors(cdvi(:), :);
    d = sum((c_descr_vectors - descrs_vectors).^2, 2); % distance from each test descriptor to its k nn
    d = reshape(d', k, [])';
    [val inds] = min(d, [], 2);  % inds are column indices for best descriptor in each row of best_descrs{sp}
    subs = [(1:size(best_descrs,1))' inds]; % turn column indices into subscripts
    inds = sub2ind(size(d), subs(:,1), subs(:,2)); % proper indices
    best_descrs = best_descrs(inds); % list if best descriptors for each spoke
end