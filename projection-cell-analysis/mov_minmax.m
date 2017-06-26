function [mnx]=mov_minmax(mf)
  % input a matfile created with cnmfe so that it has sizY and Y
  siz = mf.sizY;
  indices = randi(siz(3)-3000, 3000, 1);
  indices = sort(indices + 3000);
  y1 = mf.Y(:,:, 1:3000);
  y2 = zeros(size(y1), 'uint16');
  for i=1:3000
    y2(:,:,i) = mf.Y(:,:, indices(i));
  end
  y = cat(3, y1, y2);
  clear y1 y2
  mx = max(y, [], 3);
  mn = min(y, [], 3);
  mnx = [prctile(mn(:), 5) prctile(mx(:), 95)];
end
