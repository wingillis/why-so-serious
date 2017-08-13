function DELTAC=delta_coefficients(DATA, WIN, PAD)
  if nargin<3 | isempty(PAD), PAD=1; end
  if nargin<2 | isempty(WIN), WIN=2; end
  if nargin<1, error('Need DATA matrix to continue'); end

  if isvector(DATA)
      DATA=DATA(:)';
  end

  if PAD==1
  	DATA=[zeros(size(DATA,1),WIN) DATA  zeros(size(DATA,1),WIN)];
  elseif PAD==2
  	DATA=[ones(size(DATA,1),WIN).*repmat([DATA(:,1)],[1 WIN]) DATA ones(size(DATA,1),WIN).*repmat([DATA(:,end)],[1 WIN])];
  end

  WIN=round(WIN);

  [rows,columns]=size(DATA);

  % lose the edges via the window

  DELTAC=zeros(rows,columns-(2*(WIN+1)));

  for i=WIN+1:columns-(WIN)

  	deltanum=sum(repmat(1:WIN,[rows 1]).*(DATA(:,i+1:i+WIN)-DATA(:,i-WIN:i-1)),2);
  	deltaden=2*sum([1:WIN].^2);

  	DELTAC(:,i-(WIN))=deltanum./deltaden;
  end

end
