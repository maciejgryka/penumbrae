function matte = reconstructMatte(matte, descr)
    for s = 1:length(descr.slices_matte)
        matte = improfileWrite2(matte, descr.points(s, 1, :), descr.points(s, 2, :), descr.slices_matte{s});
%         matte = improfileWrite2(matte, descr.center, descr.center, descr.center_pixel);
    end
end