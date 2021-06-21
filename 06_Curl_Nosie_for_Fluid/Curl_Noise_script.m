seed        =  25;
size        = 512;
n_tiles     =   5;
n_octaves   =   10;
persistence =0.315;

rng(seed);

Psi      = zeros(size);
idxs    = 1:n_octaves;
max_amp = sum(persistence.^(idxs-1));

for i = idxs
    Psi = Psi + ...
        imresize(rand(n_tiles*i), ...
                [size size],"cubic")*...
        persistence^(i-1)/...
        max_amp;
end

Psi = Psi./n_tiles;

[dNdx,dNdy] = gradient(Psi);

vx =  dNdy;
vy = -dNdx;

n_particles = 100;
END_TIME = 100;

dt = 1;
A = 100 * size;

px = (size-2)*rand(n_particles,1)+1;
py = (size-2)*rand(n_particles,1)+1;

for t = 1:END_TIME
    px_grid = round(px);
    py_grid = round(py);
        
    px_grid(px_grid<1) = 1;
    px_grid(size<px_grid) = size;

    py_grid(py_grid<1) = 1;
    py_grid(size<py_grid) = size;
    
    for i = 1:n_particles
        pvx = vx(px_grid(i),py_grid(i));
        pvy = vy(px_grid(i),py_grid(i));
        
        px(i) = px(i) + A * pvx * dt;
        py(i) = py(i) + A * pvy * dt;
    end
    
    cla;
    scatter(px,py);
    hold on
    quiver(vx,vy);
    xlim([0,size]);
    ylim([0,size]);
    pbaspect([1 1 1]);
    drawnow;
    
end