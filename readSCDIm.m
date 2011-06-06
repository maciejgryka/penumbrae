function im = readSCDIm(path)
% read single-channel, image of ype double
    im = imread(path);
    if size(im,3) > 1
        im = im(:,:,1);
    end
    
    if isa(im, 'uint8')
        im = im ./ 255;
    end
end