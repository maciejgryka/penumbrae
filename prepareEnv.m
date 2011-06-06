function [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv(date, suffix)
    img_date = date;
    shad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_', suffix, '_shad.tif']);
    noshad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date, '_', suffix, '_noshad.tif']);

    shad = shad(150:199, 370:459);
    noshad = noshad(150:199, 370:459);
    
    matte = shad ./ noshad;
    
    n_angles = 1;
    len = 20;
    n_descrs = 1000;
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
%     penumbra_mask(:,[1:len, size(shad,2)-len:size(shad,2)]) = 0;
%     p_pix = find(penumbra_mask' == 1);   % penumbra pixels
    [penumbra_mask p_pix] = getPenumbraMaskAtScale(penumbra_mask, len);
    
%     % double p_pix (there are two images with the same penumbra regions)
%     p_pix = repmat(p_pix, 2, 1);
    
    % all pixels within penumbra
    [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask'), p_pix);
    n_descrs = length(p_pix);
    
%     % collection of n_descrs random points within penumbra
%     [pixel(:,2) pixel(:,1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand(n_descrs,1)+0.5)));
end