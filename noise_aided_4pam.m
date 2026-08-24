clc;
clear;
close all;

Nsym = 1e6;

pam = [-3 -1 1 3];

Ns_values = [16 64 256];

EsN0_dB = 0:2:40;

rng(1);

tx_index = randi([1 4],1,Nsym);

SER = zeros(3,length(EsN0_dB));

chunk_size = 10000;


for n = 1:length(Ns_values)

    Ns = Ns_values(n);

    Es = mean(pam.^2) * Ns;

    for s = 1:length(EsN0_dB)

        EsN0 = 10^(EsN0_dB(s)/10);

        sigma = sqrt(Es/(2*EsN0));


        P_plus = zeros(1,4);

        for k = 1:4

            d = pam(k);

            P_plus(k) = 0.5 * erfc(-d/(sigma*sqrt(2)));

        end


        errors = 0;


        for start = 1:chunk_size:Nsym

            finish = min(start + chunk_size - 1,Nsym);

            current_index = tx_index(start:finish);

            current_P = P_plus(current_index);

            M = length(current_index);


            k_positive = zeros(1,M);

            for j = 1:M

                k_positive(j) = ...
                    sum(rand(1,Ns) < current_P(j));

            end


            decision_stat = 2*k_positive - Ns;


            detected_index = zeros(1,M);

            best_likelihood = -inf(1,M);


            for k = 1:4

                p = P_plus(k);

                p = max(min(p,1-1e-12),1e-12);

                likelihood = ...
                    (decision_stat + Ns).*log(p) ...
                    - ...
                    (decision_stat - Ns).*log(1-p);


                update = likelihood > best_likelihood;

                detected_index(update) = k;

                best_likelihood(update) = ...
                    likelihood(update);

            end


            errors = errors + ...
                sum(detected_index ~= current_index);

        end


        SER(n,s) = errors/Nsym;


        fprintf('N = %d   Es/N0 = %d dB   SER = %.6g\n', ...
            Ns,EsN0_dB(s),SER(n,s));

    end

end


figure;

semilogy(EsN0_dB,SER(1,:),'-o');
hold on;

semilogy(EsN0_dB,SER(2,:),'-s');

semilogy(EsN0_dB,SER(3,:),'-^');

grid on;

xlabel('E_s/N_0 (dB)');
ylabel('Symbol Error Rate');

title('Noise-Aided 4-PAM Demodulation');

%% Theoretical 4-PAM SER

EsN0_linear = 10.^(EsN0_dB/10);

theory_SER = 1.5 * 0.5 * ...
    erfc(sqrt(0.4*EsN0_linear)/sqrt(2));

semilogy(EsN0_dB,theory_SER,'k--','LineWidth',1.5);

legend('N = 16','N = 64','N = 256','Theory (linear)');

ylim([1e-6 1]);