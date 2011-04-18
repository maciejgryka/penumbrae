function createMultipleMasks()
% Assumes that penumbrae in all images can be inspected with the same slices
    date = '2011-03-20';
    path = [date '\'];
    frameRange = 1:24;
    
    for f = frameRange
        im = rgb2gray(imread([path date '_masterLayer_' int2str(f) '.tif']));
        noshad = rgb2gray(imread([path date '_noshad_' int2str(f) '.tif']));
        mask = im ./ noshad;
        mask(isnan(mask)) = 0;
%         imwrite(mask, [path date '_mask_' int2str(f) '.tif'], 'tif', 'Compression', 'none');
        save([path date '_mask_' int2str(f) '.tif.mat'], 'mask');
    end
    slicePoints = saveSlices(2000, 200, [path date '_mask.tif']);
end