function show4plots(x, y, z)
    subplot(2,2,1);
    plot(x, y, '.');
    xlabel('matte value');
    ylabel('gradient magnitudes');
    axis([0 1 0 0.05]);
    subplot(2,2,2);
    plot(x, z, '.');
    xlabel('matte value');
    ylabel('intensity');
    axis([0 1 0 1]);
    subplot(2,2,3);
    plot(z, y, '.');
    xlabel('intensity');
    ylabel('gradient magnitudes');
    axis([0 1 0 0.05]);
    subplot(2,2,4);
    plot3(x, y, z, '.');
    set(gca, 'Projection', 'Perspective');
    xlabel('matte value');
    ylabel('gradient magnitudes');
    zlabel('intensity');
    axis([0 1 0 0.05 0 1]);
end