function [shad noshad matte penumbra_mask p_pix n_angles len n_descrs pixel] = prepareEnv(date, suffix)
    img_date = date;
    shad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_', suffix, '_shad.tif']);
    noshad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date, '_', suffix, '_noshad.tif']);

    shad = shad(150:199, 370:459);
    noshad = noshad(150:199, 370:459);
    
    matte = shad ./ noshad;
    
    n_angles = 3;
    len = 10;
    
%     [dx dy] = gradient(matte);
%     matte_abs_grad = abs(dx) + abs(dy);
%     penumbra_mask = matte_abs_grad > 0;
%     penumbra_mask(:,[1:len, size(shad,2)-len:size(shad,2)]) = 0;
%     p_pix = find(penumbra_mask' == 1);   % penumbra pixels
    load('penumbra_mask.mat');
    penumbra_mask = getPenumbraMaskAtScale(penumbra_mask, len);
    
    % pad the images with zero-borders of width len
    shad = addZeroBorders(shad, len);
    noshad = addZeroBorders(noshad, len);
    matte = addZeroBorders(matte, len);
    penumbra_mask = addZeroBorders(penumbra_mask, len);
    
    % all pixels within penumbra
    p_pix = find(penumbra_mask' == 1);
    [pixel(:,1) pixel(:,2)] = ind2sub(size(penumbra_mask'), p_pix);
    n_descrs = length(p_pix);
    
%     % collection of n_descrs random points within penumbra
%     [pixel(:,2) pixel(:,1)] = ind2sub(size(penumbra_mask), p_pix(round(length(p_pix)*rand(n_descrs,1)+0.5)));
end