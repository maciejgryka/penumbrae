function [shad noshad matte penumbra_mask n_angles scales] = prepareEnv(date, suffix)
    img_date = date;
    shad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_', suffix, '_shad.tif']);
    noshad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date, '_', suffix, '_noshad.tif']);
    penumbra_mask = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\penumbra_mask.tif']);
    shad = shad(150:249, 370:469);
    noshad = noshad(150:249, 370:469);
    
    matte = shad ./ noshad;
    
    n_angles = 4;
%     scales = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100];
    scales = [10];
    
%     [dx dy] = gradient(matte);
%     matte_abs_grad = abs(dx) + abs(dy);
%     penumbra_mask = matte_abs_grad > 0;
%     save('penumbra_mask.mat', 'penumbra_mask');
%     load('penumbra_mask.mat');
end