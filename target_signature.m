function [tgt_signature] = target_signature(rxpulses,receiver,waveform,pfa,nbr_bursts,nbr_pulses_per_burst)
    
    tgt_signature = zeros(nbr_bursts, nbr_pulses_per_burst, 2);

    for burst_idx = 1:nbr_bursts
                
        if burst_idx == 1
            first_pulse_of_burst_idx = 1;
            last_pulse_of_burst_idx = nbr_pulses_per_burst;
        else
            first_pulse_of_burst_idx = (burst_idx-1)*nbr_pulses_per_burst+1;
            last_pulse_of_burst_idx = burst_idx*nbr_pulses_per_burst;
        end
        rxpulses_burst = rxpulses(:,first_pulse_of_burst_idx:last_pulse_of_burst_idx);

        % in loaded system, noise bandwidth is half of the sample rate
        noise_bw = receiver.SampleRate/2;
        npower = noisepow(noise_bw, receiver.NoiseFigure, receiver.ReferenceTemperature);
        threshold = npower * db2pow(npwgnthresh(pfa,nbr_pulses_per_burst,'noncoherent'));

        % apply matched filter and update the threshold
        matchingcoeff = getMatchedFilter(waveform);
        matchedfilter = phased.MatchedFilter('Coefficients',matchingcoeff,'GainOutputPort',true);

        [rxpulses_burst, mfgain] = matchedfilter(rxpulses_burst);

        threshold = threshold * db2pow(mfgain);

        % compensate the matched filter delay
        matchingdelay = size(matchingcoeff,1)-1;
        % https://fr.mathworks.com/help/signal/ref/buffer.html
        rxpulses_burst = buffer(rxpulses_burst(matchingdelay+1:end),size(rxpulses_burst,1));

        % detect peaks from the integrated pulse
        pulseintegrated = pulsint(rxpulses_burst,'noncoherent');

        [peaksval,range_detect] = findpeaks(pulseintegrated,'MinPeakHeight',sqrt(threshold));

        [pulseintegrated_max,max_idx] = max(pulseintegrated);


        [p0, f0] = periodogram(rxpulses_burst(max_idx,:).',[],nbr_pulses_per_burst,waveform.PRF,'power','centered');

        tgt_signature(burst_idx,:,:) = [p0,f0];

    end
end
