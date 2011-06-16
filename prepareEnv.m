function [shad noshad matte penumbra_mask n_angles scales] = prepareEnv(date, suffix)
    img_date = date;
    shad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\', img_date, '\', img_date, '_', suffix, '_shad.tif']);
    noshad = readSCDIm(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date, '_', suffix, '_noshad.tif']);

    shad = shad(150:299, 370:559);
    noshad = noshad(150:299, 370:559);
    
    matte = shad ./ noshad;
    
    n_angles = 2;
    scales = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100];
    
    [dx dy] = gradient(matte);
    matte_abs_grad = abs(dx) + abs(dy);
    penumbra_mask = matte_abs_grad > 0;
    save('penumbra_mask.mat', 'penumbra_mask');
    load('penumbra_mask.mat');
end