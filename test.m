Sigma=5;   
height=768;
    width=1024;
    levels=5;
        % four times bigger than original image to guarantee that...
    for i=1:levels
        m=height*4/(2^(i-1)); n=width*4/(2^(i-1));

        [h1, h2] = meshgrid(-(n-1)/2:(n-1)/2,-(m-1)/2:(m-1)/2);
        hg = exp(- 0.5*(h1.^2+h2.^2) / (i*Sigma).^2);

        kernel_aux=0.1*ones(m,n,3);

        kernel_aux(:,:,1)=hg ./ sum(hg(:));
        kernel_aux(:,:,2)=kernel_aux(:,:,1);
        kernel_aux(:,:,3)=kernel_aux(:,:,1);

        % normalize
        kernel_aux(:,:,1) =  kernel_aux(:,:,1)/max(max(abs(kernel_aux(:,:,1))));
        kernel_aux(:,:,2) =  kernel_aux(:,:,2)/max(max(abs(kernel_aux(:,:,2))));
        kernel_aux(:,:,3) =  kernel_aux(:,:,3)/max(max(abs(kernel_aux(:,:,3))));

        kernel{i}=kernel_aux;
    end