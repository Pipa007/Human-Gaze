m = 5; n = 5;
sigma = 1;
[h1, h2] = meshgrid(-(m-1)/2:(m-1)/2, -(n-1)/2:(n-1)/2);
hg = exp(- (h1.^2+h2.^2) / (2*sigma^2));
kernel{1} = hg ./ sum(hg(:));
hg = exp(- (h1.^2+h2.^2) / (2*(2*sigma)^2));
kernel{2} =hg ./ sum(hg(:));