
ammountN    =  291.3;
n_tiles     =     5;
n_octaves   =   28;
persistence = 0.953;
seed        =   69;

ammountH    =  1000;

ammountO    =  0.007;
sigma       =  83.22 ;

size        =  4096;
n_particles = 163300;
vel         = 5.65;
step        =  100;
END_TIME =     50;

x = (1:size)/size-1/2;
y = transpose((1:size)/size-1/2);

rng(seed);
Psi_N     = zeros(size);
idxs      = 1:n_octaves;
max_amp   = sum(persistence.^(idxs-1));

for i = idxs
    Psi_N = Psi_N + ...
        imresize(rand(n_tiles*i), ...
                [size size],"cubic")*...
        persistence^(i-1)/...
        max_amp;
end
Psi_N = Psi_N/n_tiles;

Psi_H = x+0*y;

Object = imresize( ...
         rgb2gray(imread("Object.png"))...
        ,[size,size]);
Edge =  edge(Object);
Psi_O = imgaussfilt(transpose( ...
        double(Object)),sigma,"FilterSize",1025);

Psi = vel*(Psi_N*ammountN+Psi_H*ammountH).*(1-Psi_O*ammountO);

[dPsidx,dPsidy] = gradient(Psi);
vx =   dPsidx./sqrt(dPsidx.^2+dPsidy.^2)*size;
vy =  -dPsidy./sqrt(dPsidx.^2+dPsidy.^2)*size;

%{
fig = figure('Position',[0,0,400,200]);
tiledlayout(1,2);
nexttile;
imagesc(Psi);
nexttile;
contour(transpose(Psi));
%}

dt = 1/60;
px = size*rand(n_particles,1)*0.3;
[py,pidxs] = sort(size*rand(n_particles,1));
pc = 1:n_particles;
pc = pc(pidxs);

fig = figure('Position',[0,0,500,500]);
for t = 1:END_TIME*step
    px_grid = round(px);
    py_grid = round(py);
        
    px_grid(px_grid<1) = 1;
    px_grid(size<px_grid) = size;

    py_grid(py_grid<1) = 1;
    py_grid(size<py_grid) = size;
    
    if mod(t,step) == 0    
        cla
        hold on
        image(255*(1-Object));
        colormap gray;
        scatter(px,py,1,pc,".","CData",hsv(n_particles));
        xlim([0 size]);
        ylim([0 size]);
        pbaspect([1 1 1]);
        axis off
        hold off
        drawnow;
    end
        
    for i = 1:n_particles
        pvx = vx(px_grid(i),py_grid(i));
        pvy = vy(px_grid(i),py_grid(i));
        
        px(i) = px(i) + pvx * dt / step;
        py(i) = py(i) + pvy * dt / step;
    end 
end