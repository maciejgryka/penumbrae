function dist = evaluateDescriptorMatch(d1, d2)
    % relies on the fact that descriptors are taken from the same image and
    % therefore should have the same coords
    dist = norm(d1.center - d2.center);
end