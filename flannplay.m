function flannplay()
    dataset = single(rand(3, 10));
    testset = single(rand(3,1));
    
    

    build_params.target_precision = 0.9;
    build_params.build_weight = 0.01;
    build_params.memory_weight = 0;
    [index, parameters] = flann_build_index(dataset, build_params);

    result = flann_search(index,testset,5,parameters);

    plot3(dataset(1,:), dataset(2,:), dataset(3,:), '.b');
    hold on;
    plot3(testset(1,1), testset(2,1), testset(3,1), '.r', 'MarkerSize', 5);
    plot3(dataset(1,result), dataset(2,result), dataset(3,result), '.g');
    hold off;

    set(gca, 'Projection', 'Perspective');

    flann_free_index(index);
end