function show4plots(x, y, z)
    subplot(2,2,1);
    plot(x, y, '.');
    xlabel('matte value');
    ylabel('gradient magnitudes');
    subplot(2,2,2);
    plot(x, z, '.');
    xlabel('matte value');
    ylabel('gradient orientations');
    subplot(2,2,3);
    plot(z, y, '.');
    xlabel('gradient orientations');
    ylabel('gradient magnitudes');
    subplot(2,2,4);
    plot3(x, y, z, '.');
    set(gca, 'Projection', 'Perspective');
    xlabel('matte value');
    ylabel('gradient magnitudes');
    zlabel('gradient orientations');
end