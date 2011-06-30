function [shads noshads mattes masks n_angles scales] = prepareEnv(training_dir, file_ext)

    default_file_ext = 'png';
    default_training_dir = 'python\output\';
    
    if nargin == 0
        training_dir = default_training_dir;
        file_ext = default_file_ext;
    end
    if nargin == 1
        file_ext = default_file_ext;
    end
    
    % get list of all files with matching extension in the specified directory
    shad_files = dir([training_dir '*_shad.' file_ext]);
    noshad_files = dir([training_dir '*_noshad.' file_ext]);
    
    if length(shad_files) ~= length(noshad_files)
        error('Number of shadow and noshadow images has to match.')
    end
    
    n_ims = length(shad_files);
    
    shads = cell(n_ims);
    noshads = cell(n_ims);
    mattes = cell(n_ims);
    masks = cell(n_ims);
    
    % read the files
    for tf = 1:length(shad_files)
        [ans file_attribs] = fileattrib([training_dir shad_files(tf).name]);
        shads{tf} = readSCDIm(file_attribs.Name);

        [ans file_attribs] = fileattrib([training_dir noshad_files(tf).name]);
        noshads{tf} = readSCDIm(file_attribs.Name);
        
        mattes{tf} = shads{tf} ./ noshads{tf};
        masks{tf} = mattes{tf} > 0 & mattes{tf} < 1;
    end
    
    n_angles = 4;
%     scales = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100];
    scales = [5];
end