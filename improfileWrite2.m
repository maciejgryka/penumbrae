function im = improfileWrite2(im, p1, p2, prof)
    close all
    imshow(im, []);
    h = imline(gca, [p1(:); p2(:)]);
    bw = createMask(h);
    p = find(bw == 1);
    im(p) = interpft(prof, length(p));
end