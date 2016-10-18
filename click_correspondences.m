function [im1_pts, im2_pts] = click_correspondences(im1, im2) 
    [im1_pts, im2_pts] = cpselect(im1, im2,'Wait',true);
end
