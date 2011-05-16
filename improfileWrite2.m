function im = improfileWrite2(im, p1, p2, prof)
    p1 = p1(:);
    p2 = p2(:);
    
    dist_euc = norm(p1 - p2);
    n_pix = round(dist_euc*2);
    if n_pix == 0
        step = 0;
        pix_coords = zeros(1, 2);
    else
        step = (p1 - p2)/n_pix;
        pix_coords = zeros(n_pix, 2);
    end
    for cp = 0:n_pix
        pix_coords(cp+1, :) = round(p2 + cp*step);
    end
    pix_inds = sub2ind(size(im), pix_coords(:,2), pix_coords(:,1));
    pix_inds = unique(pix_inds);
    im(pix_inds) = interpft(prof, length(pix_inds));
%     close all
%     imshow(im, []);
%     h = imline(gca, [p1(1) p1(2); p2(1) p2(2)]);
% %     h = impoint(gca, p1(1), p1(2));
%     bw = createMask(h);
%     p = find(bw == 1);
%     im(p) = interpft(prof, length(p));
% %     im(p) = prof;
end