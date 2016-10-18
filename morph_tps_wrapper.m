function morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
    m = length(warp_frac);
    morphed_im = cell(1,m);
    for j=1:m
        wf = warp_frac(j);
        df = dissolve_frac(j);
        inter_pts = (1-wf) * im1_pts + wf * im2_pts;
        sz = size(im2);
        % im1
        [a1_x, ax_x, ay_x, w_x] = est_tps(inter_pts,im1_pts(:,1));
        [a1_y, ax_y, ay_y, w_y] = est_tps(inter_pts,im1_pts(:,2));
        morphed_im1 = morph_tps(im1, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, inter_pts,sz);

        % im2
        [a1_x, ax_x, ay_x, w_x] = est_tps(inter_pts,im2_pts(:,1));
        [a1_y, ax_y, ay_y, w_y] = est_tps(inter_pts,im2_pts(:,2));
        morphed_im2 = morph_tps(im2, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, inter_pts,sz);

        morphed_im{j} = uint8((1-df) * morphed_im1 + df * morphed_im2);
    end
end