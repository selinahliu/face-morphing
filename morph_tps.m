function morphed_im = morph_tps(im_source, a1_x, ax_x, ay_x, w_x,...
                                a1_y, ax_y, ay_y, w_y, ctr_pts, sz)
    
    [rs,cs,~] = size(im_source);
    rt = sz(1);
    ct = sz(2);
    N = rt * ct;
    
    Ufn = @(x) -(x.^2) .* log(x.^2);
    
    morphed_im = zeros([rt,ct,3]);
    n = length(ctr_pts);
    [x,y] = meshgrid(1:ct, 1:rt);
    
    target_coords = [reshape(x,[N,1]), reshape(y,[N,1])];
    fx_term1 = [ones(N,1),target_coords] * [a1_x; ax_x; ay_x];
    fy_term1 = [ones(N,1),target_coords] * [a1_y; ax_y; ay_y];
    fx_term2 = ones(N,1);
    fy_term2 = ones(N,1);
    
    
    for i=1:N
        x = target_coords(i,1);
        y = target_coords(i,2);
        term2 = (ctr_pts - (ones(n,1) * [x,y])) .^ 2; 
        term2 = sqrt(sum(term2,2));
        term2 = Ufn(term2);
        term2(isnan(term2)) = 0;
        fx_term2(i) = sum(w_x .* term2);
        fy_term2(i) = sum(w_y .* term2);
    end
    
    source_x = fx_term1 + fx_term2;
    source_x(source_x < 1) = 1;
    source_x(source_x > cs) = cs;
    source_y = fy_term1 + fy_term2;
    source_y(source_y < 1) = 1;
    source_y(source_y > rs) = rs;
    
    [X,Y] = meshgrid(1:cs,1:rs);
    source_r = interp2(X,Y,double(im_source(:,:,1)),source_x, source_y);
    source_g = interp2(X,Y,double(im_source(:,:,2)),source_x, source_y);
    source_b = interp2(X,Y,double(im_source(:,:,3)),source_x, source_y);
    
    for i=1:rt*ct
        tx = target_coords(i,1);
        ty = target_coords(i,2);
        morphed_im(ty,tx,1) = source_r(i);
        morphed_im(ty,tx,2) = source_g(i);
        morphed_im(ty,tx,3) = source_b(i);
    end
    
end

