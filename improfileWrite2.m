function im = improfileWrite2(im, p1, p2, prof)
    close all
    imshow(im, []);
    h = imline(gca, [p1(1) p1(2); p2(1) p2(2)]);
%     h = impoint(gca, p1(1), p1(2));
    bw = createMask(h);
    p = find(bw == 1);
    im(p) = interpft(prof, length(p));
%     im(p) = prof;
end