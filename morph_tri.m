function morphed_im = morph_tri(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
    im1 = double(im1);
    im2 = double(im2);
    m = length(warp_frac);
    tri = delaunay(0.5*im1_pts + 0.5*im2_pts);
    morphed_im = cell(1,m);
    
    for j=1:m
        wf = warp_frac(j);
        df = dissolve_frac(j);
        inter_shape = (1-wf) * im1_pts + wf * im2_pts;

        [r,c,~] = size(im1);
        [x,y] = meshgrid(1:c,1:r);
        coordList = [reshape(x,[r*c,1]), reshape(y,[r*c,1])];

        which_triangle = tsearchn(inter_shape, tri, coordList); % triangle each pt in inter_mesh is in
        valid_triangles = which_triangle(~isnan(which_triangle));
        valid_coords = coordList(~isnan(which_triangle),:);

        trix = inter_shape(:,1);
        trix = trix(tri);
        triy = inter_shape(:,2);
        triy = triy(tri);
        [ntri,v] = size(trix);

        flatmat = [trix,triy,ones(ntri,v)];

        triInverse = @(x) inv(vec2mat(flatmat(x,:), 3)); % x is the index of triangle

        homocoords = [valid_coords,ones(length(valid_coords),1)];
        bary = zeros(length(valid_coords),3); % bary coordinates for each point in valid_mesh
        for i=1:length(valid_coords)
            bary(i,:) = triInverse(valid_triangles(i)) * homocoords(i,:)';
        end

        % inverse warp from source image 1
        tri1x = im1_pts(:,1);
        tri1x = tri1x(tri);
        tri1y = im1_pts(:,2);
        tri1y = tri1y(tri);
        flatmat1 = [tri1x, tri1y, ones(ntri,v)];
        pos1 = zeros(length(valid_coords),3);
        for i=1:length(valid_coords)
            pos1(i,:) = vec2mat(flatmat1(valid_triangles(i),:),3) * bary(i,:)';
            pos1(i,:) = pos1(i,:) ./ pos1(i,3);
        end
        
        pos1(pos1<1) = 1;
        
        pos1x = pos1(:,1);
        pos1x(pos1x>c) = c;
        pos1y = pos1(:,2);
        pos1y(pos1y>r) = r;
        [X,Y] = meshgrid(1:c,1:r);
        source_r = interp2(X,Y,im1(:,:,1),pos1x, pos1y);
        source_g = interp2(X,Y,im1(:,:,2),pos1x, pos1y);
        source_b = interp2(X,Y,im1(:,:,3),pos1x, pos1y);
        
        interim1 = zeros(r,c,3);
        for i=1:length(pos1)
            tx = valid_coords(i,1);
            ty = valid_coords(i,2);
            interim1(ty,tx,1) = source_r(i);
            interim1(ty,tx,2) = source_g(i);
            interim1(ty,tx,3) = source_b(i);
        end

        % inverse warp from source image 2
        tri2x = im2_pts(:,1);
        tri2x = tri2x(tri);
        tri2y = im2_pts(:,2);
        tri2y = tri2y(tri);
        flatmat2 = [tri2x, tri2y, ones(ntri,v)];
        pos2 = zeros(length(valid_coords),3);
        for i=1:length(valid_coords)
            pos2(i,:) = vec2mat(flatmat2(valid_triangles(i),:),3) * bary(i,:)';
            pos2(i,:) = pos2(i,:) ./ pos2(i,3);
        end
      
        pos2(pos2<1) = 1;
    
        pos2x = pos2(:,1);
        pos2x(pos2x>c) = c;
        pos2y = pos2(:,2);
        pos2y(pos2y>r) = r;
        source_r = interp2(X,Y,im2(:,:,1),pos2x, pos2y);
        source_g = interp2(X,Y,im2(:,:,2),pos2x, pos2y);
        source_b = interp2(X,Y,im2(:,:,3),pos2x, pos2y);
        
        interim2 = zeros(r,c,3);
        for i=1:length(pos2)
            tx = valid_coords(i,1);
            ty = valid_coords(i,2);
            interim2(ty,tx,1) = source_r(i);
            interim2(ty,tx,2) = source_g(i);
            interim2(ty,tx,3) = source_b(i);
        end
        curr_im = (1 - df) * interim1 + df * interim2;
        morphed_im{j} = uint8(curr_im);
    end
end