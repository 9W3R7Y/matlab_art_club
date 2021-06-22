ammountN    =  100;
n_tiles     =     7;
n_octaves   =   28;
persistence = 0.5;
seed        =   69;

ammountH    =  363.3;

ammountO    =  0.158;
sigma       =  50 ;

size        =  4096;
n_particles =  500000;
vel         =  8.74;
step        =  10;
END_TIME =     20;

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
        double(Object)),sigma);
    
Psi = vel*(Psi_N*ammountN+Psi_H*ammountH).*(1-0.005*Psi_O);

[dPsidx,dPsidy] = gradient(Psi);
vx =   dPsidx*size+size/2;
vy =  -dPsidy*size+size/2;

%{
fig1 = figure('Position',[0,0,500,500]);
imagesc(255*Psi);
colormap gray;
%}

dt = 1/60;
px = size*rand(n_particles,1)*0.4;
[py,pidxs] = sort(size*rand(n_particles,1));
pc = 1:n_particles;
pc = pc(pidxs);

fig2 = figure('Position',[0,0,500,500]);
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
        scatter(px,py,1,pc,".","CData",jet(n_particles));
        xlim([0 size]);
        ylim([0 size]);
        pbaspect([1 1 1]);
        axis off
        hold off
        drawnow;
        
        saveas(fig2,"results\"+num2str(t/step,'%04.f')+".png");
        
    end
        
    idxs = [px_grid py_grid];
    pvx = vx(idxs);
    pvy = vy(idxs);
        
    px = px + pvx * dt / step;
    py = py + pvy * dt / step;
end