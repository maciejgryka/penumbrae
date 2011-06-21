function imp = removeBorders(im, len)
    imp = im(2:size(im,1)-len, 2:size(im,2)-len);
end