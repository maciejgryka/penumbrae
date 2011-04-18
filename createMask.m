function createMask()
    path = '2011-03-20\';
    texture = '';
%     scenarios = {['parallel_' texture], ['angle_' texture], ['disc_' texture]};
    scenarios = {['2011-03-20' texture]};

    for s = 1:length(scenarios)
        im = rgb2gray(double(imread([path scenarios{s} '_masterLayer_24.tif'])));
        noshad = rgb2gray(double(imread([path scenarios{s} '_noshad_24.tif'])));
        mask = im ./ noshad;
        ns = isnan(mask);
        mask(ns) = 0;
        imwrite(mask, [path scenarios{s} '_mask.tif'], 'Compression', 'none');
        slicePoints = saveSlices(2000, 200, [path scenarios{s} '_mask.tif']);
        imshow(mask); hold on;
        for l = 1:(size(slicePoints, 1)/2)-2
            plot(slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), '.r');
        end
        hold off;
    end
end