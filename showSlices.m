function showSlices()
    path = '2011-03-18\';
    texture = 'disc';
%     scenarios = {['parallel_' texture], ['angle_' texture], ['disc_' texture]};
    scenarios = {['2011-03-18_' texture]};

    for s = 1:length(scenarios)
        im = rgb2gray(imread([path scenarios{s} '_shadow.tif']));
        noshad = rgb2gray(imread([path scenarios{s} '_noshad.tif']));
        mask = im ./ noshad;
        load([path scenarios{s} '_mask.tif' '_profile.mat'], 'x', 'y', 'slicePoints');
        nLines = size(slicePoints, 1)/2;

        meanProf = getMeanProfile(mask, slicePoints);
        meanProf = meanProf';
%         meanProf(meanProf < 0.0001) = 1;

        fprintf(['Inspecting ' scenarios{s} ' scanario.\n'])
        fprintf('Press Enter for next slice, type "skip" (see all profiles from this scenario) or "exit".\n');
        usrcmd = '';

        ima = im;
        
        for l = 1:nLines-2
%             subplot(2,2, 1);
%             maskProf = improfile(mask, slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), length(meanProf));
%             plot(improfile(mask, slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2)));
%             axis([0 100 -0.1 1.1]);

%             subplot(2,2, 2);
            currProf = improfile(im, slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), length(meanProf));
%             plot(improfile(im, slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2)));
%             axis([0 100 -0.1 1.1]);

%             subplot(2,2,3); hold on;
%             imshow(mask);
%             plot(slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), 'r');
%             hold off;

%             subplot(2,2,4);hold on;
            newProf = currProf./meanProf;
            ns = isnan(newProf);
            newProf(ns) = 0;
            
            ima = improfileWrite(ima, slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), newProf);
            
%             plot(slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), 'r');
            
%             imshow(ima);
%             plot(slicePoints((l-1)*2+1:(l-1)*2+2, 1), slicePoints((l-1)*2+1:(l-1)*2+2, 2), 'r');
%             hold off;

%             usrcmd = input('', 's');
%             if strcmp(usrcmd, 'skip') || strcmp(usrcmd, 'exit')
%                 break
%             end
        end
        imshow(ima);
        if strcmp(usrcmd, 'exit')
            break
        end

%         subplot(1,2,1);
%         showAll(mask, slicePoints); hold on;
%         plot(meanProf, 'r', 'LineWidth', 3);
%         axis([0 50 -0.1 1.1]);hold off;
%         subplot(1,2,2);
%         showAll(im, slicePoints);
%         axis([0 50 -0.1 1.1]);

%         usrcmd = input('', 's');
    end
end