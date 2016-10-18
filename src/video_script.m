clc; clear;
%% configurations
size_large = 0;
import_pts = 1;
do_trig = 0;

%% reading in images
if size_large
    im1 = imread('images/im1Large.jpg');
    im2 = imread('images/im2Large.jpg');
else
    im1 = imread('images/im1Small.jpg');
    im2 = imread('images/im2Small.jpg');
end

[r1,c1,~] = size(im1);
[r2,c2,~] = size(im2);

if r1 > r2
    scale = r2 / r1;
    im1 = imresize(im1, scale);
    
end
if c1 > c2
    scale = c2 / c1;
    im1 = imresize(im1, scale);
    
end
[r1,c1,~] = size(im1);
rdiff = max(0,r2 - r1);
cdiff = max(0,c2 - c1);
im1 = padarray(im1, [rdiff, cdiff],'post');

%% reading in im1_pts and im2_pts from pre-saved points or fresh user input


if import_pts
    if size_large
        im1Large = load('images/im1Large_pts.mat');
        im2Large = load('images/im2Large_pts.mat');
        im1_pts = im1Large.im1_pts;
        im2_pts = im2Large.im2_pts;
        cpselect(im1,im2,im1_pts,im2_pts);
    else
        im1Small = load('images/im1Small_pts.mat');
        im2Small = load('images/im2Small_pts.mat');
        im1_pts = im1Small.im1_pts;
        im2_pts = im2Small.im2_pts;
        cpselect(im1,im2,im1_pts,im2_pts);
    end    
else
    [im1_pts, im2_pts] = click_correspondences(im1,im2);
end


steps = linspace(0,1,60);
im1 = double(im1);
im2 = double(im2);

%% choosing to morph using triangulation (0) or thin-plate spline (1)

if do_trig
    morphed_im = morph_tri(im1, im2, im1_pts, im2_pts, steps, steps);
    fname = 'vid_tri';
else
    morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, steps, steps);
    fname = 'vid_tps';
end

%% creating the video
vid = VideoWriter(fname);
%vid.FrameRate = 15;
open(vid);

% write images to video file
for i=1:length(morphed_im)
    writeVideo(vid, morphed_im{i});
end

% wrapping up
close(vid);
disp('finished the movie!');

