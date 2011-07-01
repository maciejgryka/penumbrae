function drawMatches()
    [shads noshads mattes masks masks_s pixels_s n_angles scales] = prepareEnv('python/output/test/', 'png');
    
    k = 5;
    sc = 1;
    shad = shads{1};
    len = scales(sc);
    
    % load training data
    data_file_path = ['descrs/descrs_', int2str(n_angles), 'ang_', int2str(scales(sc)), 'sc.mat'];
    if exist(data_file_path, 'file')
        load(data_file_path);
    else
        error('No data at this scale\n');
    end
    
%     error_gt = zeros(n_descrs, 1);
%     error_gt_img = zeros(size(shad));
%     inconsistency = zeros(n_descrs, 1);
%     inconsistency_img = zeros(size(shad));
    
    cols = ['r' 'g' 'b' 'c' 'm' 'y' 'w'];
    
    for n = 1:length(descrs)
        c_descr = PenumbraDescriptor(shad, pixels_s{1,sc}(n,:), n_angles, len, masks_s{sc});
        
%         [best_descrs dists] = knnsearch(slices_shad,cat(1,c_descr.slices_shad_cat),'K', k);
        [best_descrs dists] = knnsearch(spokes,c_descr.spokes,'K', k, 'NSMethod', 'kdtree');

        subplot(2,2,1);
        plot(c_descr.spokes(1,:), 'k');
        hold on;
        for nn = 1:k
            plot(spokes(best_descrs(1,nn),:), cols(nn));
        end
        hold off;
        
        subplot(2,2,2);
        plot(c_descr.spokes(2,:), 'k');
        hold on;
        for nn = 1:k
            plot(spokes(best_descrs(2,nn),:), cols(nn));
        end
        hold off;
        
        subplot(2,2,3);
        plot(c_descr.spokes(2,:), 'k');
        hold on;
        for nn = 1:k
            plot(spokes(best_descrs(3,nn),:), cols(nn));
        end
        hold off;
        
        subplot(2,2,4);
        plot(c_descr.spokes(3,:), 'k');
        hold on;
        for nn = 1:k
            plot(spokes(best_descrs(4,nn),:), cols(nn));
        end
        hold off;
    end
end