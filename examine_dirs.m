im = shadow;
[height, width] = size(im);

ps = 10; % patch size
hps = ps/2;

im = imfilter(im, fspecial('gaussian', 2*ps, 1.5*ps));

step = 10;
lineLen = hps;

imshow(im);
hold on;
for y = hps+2:step:height-ps-1
    for x = hps+2:step:width-ps-1
        patch = im(y-hps:y+hps, x-hps:x+hps);
%         patch = [1 1 1 1; 1 1 1 0; 1 1 0 0; 1 1 0 0; 1 1 0 0];
        dominantDir = dominantGradientDir(patch);
        xo = cos(dominantDir);
        yo = sin(dominantDir);

%         imshow(patch);
%         hold on;
        plot([x+hps-lineLen*xo x+hps+lineLen*xo], [y+hps-lineLen*yo y+hps+lineLen*yo], 'r', 'linewidth', 1);
%         hold off;
%         plot([x x+ps x+ps x], [y y y+ps y+ps], '*r');
    end
end
hold off;