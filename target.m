function target(nbr_targets,nbr_blades,receiver_noise,change_seed,nbr_bursts,nbr_pulses_per_burst)

    for sample_idx = 1:nbr_targets
        
        %% Seed
        
        if change_seed
            rng(sample_idx);
            seed = sample_idx;
        else
            seed = 1;
        end
        
        %% Radar

        c = physconst('LightSpeed');

        % carrier frequency
        fc = 5e9;
        % waveform sample rate "Note that we set the sampling rate as twice the bandwidth." https://fr.mathworks.com/help/phased/ug/designing-a-basic-monostatic-pulse-radar.html
        fs = 1e6;

        % calculate initial threshold
        pfa = 1e-6;

        prf = 50e3;
        maxrange = c/(2*prf);
        maxspeed = dop2speed(prf/2,c/fc)/2;
        nbr_pulses = nbr_bursts*nbr_pulses_per_burst; % each set of bursts defines one Doppler signature

        % radar location and velocity
        radarpos = [0;0;0];
        radarvel = [0;0;0];

        antenna = phased.IsotropicAntennaElement('FrequencyRange',[1e9 9e9]);
        transmitter = phased.Transmitter('Gain',20,'InUseOutputPort',true);

        %% Targets
        
        % positions spread along the first axis only
        randpos = (0.15*maxrange)*rand(1) + 0.1*maxrange;
        %randpos = 0.1*maxrange;
        tgts(sample_idx).pos = [randpos;0;500];
        
        % velocities spread along the first axis only, 
        randvel = (0.5*maxspeed)*rand(1)-0.25*maxspeed;
        tgts(sample_idx).vel = [randvel;0;0];
        
        Nblades  = nbr_blades;
        bladesRCS = [10];
        bladesRCS = cat(2,bladesRCS,0.5*ones(1,Nblades));
        bladeang = (0:Nblades-1)*2*pi/Nblades;
        
        % in meters https://fr.mathworks.com/help/radar/ug/introduction-to-micro-doppler-effects.html
        tgts(sample_idx).bladelen = 4.5+2.5*rand(1);
        
        % helicopters, airplanes and drones have blades rotating at ~ 200 to a few thousands RPMs
        tgts(sample_idx).rpm = 400+250*rand(1);
        bladerate = deg2rad((tgts(sample_idx).rpm/60)*360);  % rps -> rad/sec

        helicop = phased.RadarTarget('MeanRCS',bladesRCS,'PropagationSpeed',c,'OperatingFrequency',fc,'Model','Nonfluctuating');
        
        tgtmotion = phased.Platform('InitialPosition',tgts(sample_idx).pos,'Velocity',tgts(sample_idx).vel);

        %% Radar transmission parameters

        waveform = phased.RectangularWaveform('SampleRate',fs,'PulseWidth',2e-6,'OutputFormat','Pulses','PRF',prf,'NumPulses',1);
        c = physconst('LightSpeed');
        SNR = npwgnthresh(1e-6,1,'noncoherent');
        lambda = c/helicop.OperatingFrequency;
        tau = waveform.PulseWidth;
        Ts = 290;
        dbterm = db2pow(SNR - 2*transmitter.Gain);
        Pt = (4*pi)^3*physconst('Boltzmann')*Ts/tau/10/lambda^2*maxrange^4*dbterm;

        transmitter.PeakPower = Pt;
        
        radiator = phased.Radiator('PropagationSpeed',c,'OperatingFrequency',fc,'Sensor',antenna);

        % forward propagation channel
        channel1 = phased.FreeSpace('PropagationSpeed',c,'OperatingFrequency',fc,'TwoWayPropagation',false);

        % backward propagation channel
        channel2 = phased.FreeSpace('PropagationSpeed',c,'OperatingFrequency',fc,'TwoWayPropagation',false);

        collector = phased.Collector('PropagationSpeed',c,'OperatingFrequency',fc,'Sensor',antenna);
        
        receiver = phased.ReceiverPreamp('NoiseMethod','Noise power','NoisePower',1e-15,'EnableInputPort',true,'SeedSource','Property','Seed',seed);
        tgts(sample_idx).noisepow = 1e-15;
        %end

        % pulse-wide time axis
        fast_time_grid = unigrid(0,1/fs,1/prf,'[)');

        % pre-allocate array for improved processing speed
        rxpulses = zeros(numel(fast_time_grid),nbr_pulses_per_burst*10);

        %% Radar transmission

        for n = 1:nbr_pulses

            % update helicopter
            t = (n-1)/prf;
            [tgtpos,tgtvel,tgtang] = helicopmotion(t,tgtmotion,bladeang,tgts(sample_idx).bladelen,bladerate,prf,radarpos);

            % simulate echos for other targets
            wf = waveform();
            [wf,txstatus] = transmitter(wf);
            wf = radiator(wf,tgtang);
            wf = channel1(wf,radarpos,tgtpos,radarvel,tgtvel);
            wf = helicop(wf);
            wf = channel2(wf,tgtpos,radarpos,tgtvel,radarvel);
            wf = collector(wf,tgtang);
            rxpulses(:,n) = receiver(wf,~txstatus);
        end
        
        %% Get Doppler signature
        tgt_signature = target_signature(rxpulses,receiver,waveform,pfa,nbr_bursts,nbr_pulses_per_burst);
        
        %% Generate struct to save the sample
        
        tgts(sample_idx).signature = tgt_signature;
        tgts(sample_idx).sigcov = cov(10*log(tgt_signature(:,:,1)));
        
    end
    
    if not(receiver_noise)
        noise_string = "_lowNoise";
    else
        noise_string = "";
    end
    
    if not(change_seed)
        seed_string = "_noSeed";
    else
        seed_string = "";
    end

    save("./data/helicopters_"+string(nbr_targets)+"_"+string(nbr_blades)+"_"+string(nbr_pulses_per_burst)+"_"+noise_string+seed_string+".mat",'tgts');
end
