function matte = reconstructMatte(matte, c_descr, db_descr)
    for s = 1:length(db_descr.slices_matte)
        % == Insert only center pixels ==
        matte = improfileWrite2(matte, c_descr.center, c_descr.center, db_descr.center_pixel);
        
%         % == Insert whole slices ==
%         matte = improfileWrite2(matte, descr.points(s, 1, :), descr.points(s, 2, :), descr.slices_matte{s});
%         % TODO: this is a dirty (and slow, and shamelessly uses ground 
%         % truth) fix to mitigate pasting the slices upside-down, which 
%         % happens to vertical slices sometimes for some reason - need to 
%         % investigate
%         p1 = improfile(matte, descr.points(s,1:2,1), descr.points(s, 1:2, 2));
%         p2 = improfile(true_matte, descr.points(s,1:2,1), descr.points(s,1:2, 2));
%         if mean((p1-p2).^2) > mean((p1-flipud(p2)).^2)
%             matte = improfileWrite2(matte, descr.points(s, 1, :), descr.points(s, 2, :), flipud(descr.slices_matte{s}));
%         end

%         % == Insert patches ==
%         p_size = 10;
%         corners = [descr.center + [ 10  10]; ...
%                    descr.center + [ 10 -10]; ...
%                    descr.center + [-10 -10]; ...
%                    descr.center + [-10  10];];
        
    end
end