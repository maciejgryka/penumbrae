im = imread('C:\Work\research\shadow_removal\penumbrae\images\2011-04-18\2011-04-14_rough1_shadow.tif');
noshad = imread('C:\Work\research\shadow_removal\penumbrae\images\2011-04-18\2011-04-14_rough1_noshad.tif');

im = im(:,:,1);

p = getRandomImagePoint(im);

n_angles = 1;
len = 100;

cDescr = PenumbraDescriptor(im, p, n_angles, len);

load('descrs.mat');

best_descr = 0;
min_err_pdist = [Inf, Inf];
min_err = Inf;

for d = 1:size(descrs, 1)
    dbSlice = descrs{d}.slices_im{1};
    cSlice = cDescr.slices_im{1}(1:length(dbSlice));
%     subplot(1,2,1);
%     plot(cSlice);
%     subplot(1,2,2);
%     plot(dbSlice);
    
    err = mean((dbSlice - cSlice).^2);
    
    if err < min_err
        best_descr = d;
        min_err = err;
        min_err_pdist = abs(cDescr.center - descrs{d}.center);
    end
end

min_err
dbSlice = descrs{best_descr}.slices_im{1};
cSlice = cDescr.slices_im{1}(1:length(dbSlice));
subplot(2,2,1);
plot(cSlice);
subplot(2,2,2);
plot(dbSlice);
subplot(2,2,3);
drawDescr(im, cDescr);
subplot(2,2,4);
drawDescr(im, descrs{best_descr});