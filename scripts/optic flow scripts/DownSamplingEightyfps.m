CJme = readmatrix("jonathan_trial1_isometric_everters.txt");
CJmecopy = CJme;

for i = 2:length(CJme) - 1
    if i < 1635239
        CJmecopy(i,:) = [0 0 0 0];
    end
    
    
    if (CJmecopy(i,4) < 1) && (CJmecopy(i-1,4) < 1) && (CJmecopy(i+1,4) < 1)
        CJmecopy(i,:) = [0 0 0 0];
    else
        CJmecopy(i,2) = CJmecopy(i,2)*93.9689 - 1.20168;
    end
    
    
    
end

CJmecopy(1,:) = [0 0 0 0];
CJmecopy(length(CJmecopy),:) = [0 0 0 0];


%%
%remove first 47%, so starting at point 1635239

%{
???????????????
if (CJmecopy(length(CJme),4) < 1) && (CJmecopy(length(CJme)-1,4) < 1)
    CJmecopy(i,:) = [0 0 0 0];
end
if (CJmecopy(1,4) < 1) && (CJmecopy(2,4) < 1)
    CJmecopy(i,:) = [0 0 0 0];
end
%}

%{
remove row:
A(2,:) = []
remove col:
A(:,3) = []
%}

%%
A_part_sync = CJmecopy(:, 4);
A_part_time = CJme(:, 1);
A_part_torque = CJmecopy(:, 3);
plot(A_part_time,A_part_torque)
