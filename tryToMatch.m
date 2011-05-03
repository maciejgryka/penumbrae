% clear all
img_date = '2011-05-03';
shad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough1_shad.tif']);
noshad = imread(['C:\Work\research\shadow_removal\penumbrae\images\' img_date '\' img_date '_rough1_noshad.tif']);

shad = shad(:,:,1);
noshad = noshad(:,:,1);

% hsize = [50, 50];
% shad = imfilter(shad, fspecial('gaussian', hsize, 20), 'replicate');
% noshad = imfilter(noshad, fspecial('gaussian', hsize, 20), 'replicate');

matte = shad ./ noshad;

n_angles = 1;
len = 100;

[dx dy] = gradient(matte);
matte_abs_grad = abs(dx) + abs(dy);
penumbra_mask = matte_abs_grad > 0;
    
p = getRandomImagePoint(shad);

while penumbra_mask(p(2), p(1)) == 0
    p = getRandomImagePoint(matte);
end

c_descr = PenumbraDescriptor(shad, p, n_angles, len, penumbra_mask);

load('descrs.mat');
% best_descr = 0;
% best_slice = 0;
% min_err_pdist = [Inf, Inf];
% min_err = Inf;

[best_slice best_descr] = matchDescrs(c_descr, descrs);

% for d = 1:size(descrs, 1)
%     c_slice = c_descr.slices_shad{1};
%     for s = 1:length(descrs{d}.slices_shad)
%         db_slice = imresize(descrs{d}.slices_shad{1}, [length(c_slice) 1]);
%     %     subplot(1,2,1);
%     %     plot(c_slice);
%     %     subplot(1,2,2);
%     %     plot(db_slice);
% 
%         err = mean((db_slice - c_slice).^2);
% 
%         if err < min_err
%             best_slice = s;
%             best_descr = d;
%             min_err = err;
%             min_err_pdist = abs(c_descr.center - descrs{d}.center);
%         end
%     end
% end

% min_err
% db_slice = descrs{best_descr}.slices_shad{best_slice};
% c_slice = c_descr.slices_shad{1};
% subplot(2,2,[1,3]);
% plot(c_slice, 'r'); hold on;
% plot(db_slice); hold off;
subplot(1,2,1);
drawDescr(shad, c_descr, 'r');
subplot(1,2,2);
drawDescr(matte, descrs{best_descr});