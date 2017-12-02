function check_cnmfe_vars(fname)
	if endsWith(fname, '.mat')
		mf = matfile(fname, 'Writable', true);
		if ~isfield(mf, 'Ysiz')
			mf.Ysiz = mf.sizY;
		end
	else
		return
	end
end
