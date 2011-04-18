function showAll(im, slicePoints)
    nLines = size(slicePoints, 1)/2;
    hold on;
    for l = 1:nLines-2
        rcolor = [rand rand rand];
        plot(improfile(im, slicePoints((l-1)*2+1:(l-1)*2+2, 1),... 
                             slicePoints((l-1)*2+1:(l-1)*2+2, 2), 50, 'bicubic'),...
                             'color', rcolor);
    end
    hold off;
end