function saveDescriptors(shad, noshad)
%     img_date = '2011-05-16';
%     if nargin ~= 2
%         shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad_small50.tif']);
%         noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_noshad_small50.tif']);
%         
%         shad = shad(:,:,1);
%         noshad = noshad(:,:,1);
%         
%         if isa(shad, 'uint8')
%             shad = double(shad)/255;
%             noshad = double(noshad)/255;
%         end
%         
% %         shad = shad(150:199, 370:419);
%     end
%     
%     matte = shad ./ noshad;
%     
%     n_angles = 1;
%     len = 20;
%     n_descrs = 1000;
%     
% 
%     
%     [dx dy] = gradient(matte);
%     matte_abs_grad = abs(dx) + abs(dy);
%     penumbra_mask = matte_abs_grad > 0;
% %     penumbra_mask  = imdilate(penumbra_mask, strel('disk',2,0));
%     p_pix = find(penumbra_mask == 1);   % penumbra pixels
%     
%     % all pixels within penumbra
%     [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask), p_pix);
%     n_descrs = length(p_pix);
%     
% %     % collection of n_descrs random points within penumbra
% %     [pixel(:,2) pixel(:,1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand(n_descrs,1)+0.5)));
    
    [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv('2011-05-16');

    descrs = repmat(PenumbraDescriptor(), n_descrs, 1);
    
    for n = 1:n_descrs
%         [pixel(2) pixel(1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand()+0.5)));

        descrs(n) = PenumbraDescriptor(shad, pixel(n,:), n_angles, len, penumbra_mask, matte);
        if isnan(descrs(n).points)
            n = n-1;
        end
    end
    
    % concatenate slices_shad and slices_matte arrays and put the in one 
    % big matrix with dimensions     [(n_descrs*n_angles) X len]
    slices_shad = gradient(cat(1,descrs(:).slices_shad));
    slices_matte = gradient(cat(1,descrs(:).slices_matte));
    
%     drawDescr(shad, descrs);
    save('descrs_small_all_30.mat', 'descrs', 'slices_shad', 'slices_matte');
end