% each target will generate as many samples as there are bursts
nbr_targets = 3000;

nbr_bursts = 64;
% each doppler spectrum will be computed over a complete burst
nbr_pulses_per_burst = 64;

% add receiver noise for diversity
receiver_noise = true;

% change seed for each target for diversity
change_seed = true;

% trick to launch 4 function calls in parallel https://fr.mathworks.com/matlabcentral/answers/41930-parallel-computing-run-two-function-simultaneously
parfor i = 1:4
    if i==1
        target(nbr_targets,1,receiver_noise,change_seed,nbr_bursts,nbr_pulses_per_burst);
    elseif i==2
        target(nbr_targets,2,receiver_noise,change_seed,nbr_bursts,nbr_pulses_per_burst);
    elseif i==3
        target(nbr_targets,4,receiver_noise,change_seed,nbr_bursts,nbr_pulses_per_burst);
    else
        target(nbr_targets,6,receiver_noise,change_seed,nbr_bursts,nbr_pulses_per_burst);
    end
end
