function [a1, ax, ay, w] = est_tps(ctr_pts, target_value)
    n = length(ctr_pts);
    
    % compute matrix K
    ctr_pts_x = ctr_pts(:,1);
    ctr_pts_y = ctr_pts(:,2);
    k1x = repmat(ctr_pts_x, [1,n]);
    k2x = repmat(ctr_pts_x',[n 1]);
    k1y = repmat(ctr_pts_y, [1,n]);
    k2y = repmat(ctr_pts_y',[n 1]);
    Kx = (k1x - k2x).^2;
    Ky = (k1y - k2y).^2;
    K = sqrt(Kx + Ky);
    
    K = -(K.^2) .* log(K.^2); % U function on K
    K(isnan(K)) = 0;
    V = [target_value; zeros(3,1)];
    P = [ctr_pts, ones(n,1)];
    
    model = [K,P;P',zeros(3,3)];
    model = model + (0.00000001 * eye(n+3));
    output = model \ V;     % OR inv(model) * V;
    
    w = output(1:n,1);
    ax = output(n+1,1);
    ay = output(n+2,1);
    a1 = output(n+3,1);
end