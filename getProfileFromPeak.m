function [prof p1 p2] = getProfileFromPeak(im, p1, p2, n)
%GETPROFILEFROMPEAK returns intensity profile of a shadow between two
%points P1 and P2 of length N starting from the end of penumbra (first
%completely unshadowed pixel)
    [cx, cy, prof] = improfile(im, [p1(1) p2(1)], [p1(2) p2(2)]);
        
    peakIndex = find(prof == 1, 1);
    
    p1 = [cx(peakIndex - n) cy(peakIndex - n)];
    p2 = [cx(peakIndex) cy(peakIndex)];
    prof = prof(peakIndex-n:peakIndex);
end