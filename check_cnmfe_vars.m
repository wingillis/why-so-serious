function check_cnmfe_vars(fname)
	mf = matfile(fname, 'Writable', true);
	if ~isfield(mf, 'Ysiz')
		mf.Ysiz = mf.sizY;
	end
end
