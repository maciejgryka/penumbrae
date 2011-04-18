function inspectMultipleMasks()
    date = '2011-03-20';
    path = [date '\'];
    frameRange = 1:24;
    
    load([path date '_mask.tif' '_profile.mat'], 'x', 'y', 'slicePoints');
    nLines = size(slicePoints, 1)/2;
    
    for f = frameRange
        f
        im = rgb2gray(double(imread([path date '_masterLayer_' int2str(f) '.tif'])));
        noshad = rgb2gray(imread([path date '_noshad_' int2str(f) '.tif']));
        mask = im ./ noshad;
        [meanProf stdProf profs] = getMeanProfile(mask, slicePoints);

        fig = figure('visible','off', 'color', [0.5 0.5 0.5]);
        subplot(2,1,1);
        imshow(mask, 'Border', 'tight');
        subplot(2,1,2);
        plot(meanProf);
        hold on;
        plot(meanProf + stdProf, 'r');
        plot(meanProf - stdProf, 'r');
        axis([0 450 0 1.5]);
        print(fig, '-r72', '-dtiff', [path date '_' int2str(f) '.tif']);
    end
    set(fig,'visible','on');
end