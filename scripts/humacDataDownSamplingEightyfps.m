CJme = readmatrix("jonathan_trial2_isokinetic_inverters.txt");
CJmecopy = CJme;

A_part_sync = CJmecopy(:, 4);

ultrasoundTimes = find(A_part_sync); %this finds all non-zero elemeents of sync


CJmeUltrasound = CJme(ultrasoundTimes(1):ultrasoundTimes(end),:);

downsampleConst = 500;

times = CJmeUltrasound(:,1); 
times = downsample(times,downsampleConst);

torques = CJmeUltrasound(:,2); 
torques = downsample(torques,downsampleConst);

positions  = CJmeUltrasound(:,3); 
positions  = downsample(positions,downsampleConst);

