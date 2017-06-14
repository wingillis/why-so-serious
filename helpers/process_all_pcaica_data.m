% traverse all directories to look for folder with saved data

% what are the dirs?
top_dirs = dir('*');
is_dir = [top_dirs.isdir];
top_dir_cell = struct2cell(top_dirs);
notdot = and(~cellfun(@(x) strcmp('.', x), top_dir_cell(1,:)), ~cellfun(@(x) strcmp('..', x), top_dir_cell(1,:)));
dir('processedMovies-ICs*-Objects');
