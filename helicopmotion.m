function [scatterpos,scattervel,scatterang] = helicopmotion(t,tgtmotion,BladeAng,ArmLength,BladeRate,prf,radarpos)

Nblades  = size(BladeAng,2);

[tgtpos,tgtvel] = tgtmotion(1/prf);

RotAng     = BladeRate*t;
scatterpos = [0 ArmLength*cos(RotAng+BladeAng);0 ArmLength*sin(RotAng+BladeAng);zeros(1,Nblades+1)]+tgtpos;
scattervel = [0 -BladeRate*ArmLength*sin(RotAng+BladeAng);...
    0 BladeRate*ArmLength*cos(RotAng+BladeAng);zeros(1,Nblades+1)]+tgtvel;

[~,scatterang] = rangeangle(scatterpos,radarpos);

end