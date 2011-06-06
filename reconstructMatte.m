function matte = reconstructMatte(matte, coords, matte_val)
%     matte = improfileWrite2(matte, coords, coords, matte_val);
    matte(coords(2), coords(1)) = matte_val;
end