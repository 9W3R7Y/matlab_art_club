%{
seed        =   32;
size        =  512;
n_tiles     =     5;
n_octaves   =   28;
persistence = 0.706;
noise       =   64.7;
pointForce  =  10.8;
vel         = 9.2;
n_particles = 5950000;
END_TIME =     100;
%}

seed        =   32;
size        =  512;
n_tiles     =     5;
n_octaves   =   28;
persistence = 0.706;
noise       =   64.7;
pointForce  =  50;
vel         = 9.2;
n_particles = 5950000;
END_TIME =     100;

rng(seed);

PsiN       = zeros(size);
idxs    = 1:n_octaves;
max_amp = sum(persistence.^(idxs-1));

for i = idxs
    PsiN = PsiN + ...
        imresize(rand(n_tiles*i), ...
                [size size],"cubic")*...
        persistence^(i-1)/...
        max_amp;
end

PsiN = PsiN/n_tiles;

x = (1:size)/size-1/2;
y = (1:size)/size-1/2;

PsiP = sqrt(x.^2+transpose(y.^2));

Psi = vel*(PsiN*noise+PsiP*pointForce);

[dPsidx,dPsidy] = gradient(Psi);

vx =   dPsidx;
vy =  -dPsidy;

vx = vx*size;
vy = vy*size;

dt = 1/60;

%init
[px,pidxs] = sort(size*rand(n_particles,1));
py = size*rand(n_particles,1);
pc = 1:n_particles;
pc = pc(pidxs);

fig = figure('Position',[0,0,800,800]);

frames(END_TIME) = struct('cdata', [], 'colormap', []);

for t = 1:END_TIME
    px_grid = round(px);
    py_grid = round(py);
        
    px_grid(px_grid<1) = 1;
    px_grid(size<px_grid) = size;

    py_grid(py_grid<1) = 1;
    py_grid(size<py_grid) = size;
    
    cla
    scatter(px,py,1,pc,".","CData",hsv(n_particles));
    xlim([0 size]);
    ylim([0 size]);
    pbaspect([1 1 1]);
    axis off
    
    saveas(fig,"results\"+num2str(t,'%04.f')+".png");
    
    frames(i) = getframe(fig);
    
    for i = 1:n_particles
        pvx = vx(px_grid(i),py_grid(i));
        pvy = vy(px_grid(i),py_grid(i));
        
        px(i) = px(i) + pvx * dt;
        py(i) = py(i) + pvy * dt;
    end 
end
