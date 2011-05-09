function matte = reconstructMatte(matte, descr, true_matte)
    for s = 1:length(descr.slices_matte)
        matte = improfileWrite2(matte, descr.points(s, 1, :), descr.points(s, 2, :), descr.slices_matte{s});
%         matte = improfileWrite2(matte, descr.center, descr.center, descr.center_pixel);
        p1 = improfile(matte, descr.points(s,1:2,1), descr.points(s, 1:2, 2));
        p2 = improfile(true_matte, descr.points(s,1:2,1), descr.points(s, 1:2, 2));
        
        % TODO: this is a dirty (and slow) fix to mitigate pasting the
        % slices upside-down, which happens to vertical slices sometimes
        % for some reason - need to investigate
        if mean((p1-p2).^2) > mean((p1-flipud(p2)).^2)
            matte = improfileWrite2(matte, descr.points(s, 1, :), descr.points(s, 2, :), flipud(descr.slices_matte{s}));
        end
    end
end