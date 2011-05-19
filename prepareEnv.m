function [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv(date)
    img_date = date;
    shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_plain_shad_small50.tif']);
    noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_plain_noshad_small50.tif']);

    shad = shad(:,:,1);
    noshad = noshad(:,:,1);

    if isa(shad, 'uint8')
        shad = double(shad)/255;
        noshad = double(noshad)/255;
    end

%         shad = shad(150:199, 370:419);
    
    matte = shad ./ noshad;
    
    n_angles = 1;
    len = 20;
    n_descrs = 1000;
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
%     penumbra_mask  = imdilate(penumbra_mask, strel('disk',2,0));
    p_pix = find(penumbra_mask == 1);   % penumbra pixels
    
    % all pixels within penumbra
    [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask), p_pix);
    n_descrs = length(p_pix);
    
%     % collection of n_descrs random points within penumbra
%     [pixel(:,2) pixel(:,1)] = ind2sub(size(penumbra_mask),
%     p_pix(round(length(p_pix)*rand(n_descrs,1)+0.5)));
end