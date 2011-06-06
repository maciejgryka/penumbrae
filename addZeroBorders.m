function imp = addZeroBorders(im, width)
% add zero-borders around the image with the specified witdth
    imp = zeros(size(im)+width);
    hw = width/2;
    imp(hw+1:size(imp,1)-hw, hw+1:size(imp,2)-hw) = im;
end