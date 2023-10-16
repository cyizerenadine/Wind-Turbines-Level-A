function [T2, Q, class]=faultIdentification(data, limits, loadings, latent, comp, select)
    % Get the control limits
    UpperWarLimT2 = limits(1); UpperActLimT2 = limits(2); UpperWarLimQ = limits(3); UpperActLimQ = limits(4);

    % Calculate T2 and Q scores
    T2 = t2comp(data, loadings, latent, comp);
    Q = qcomp(data, loadings, comp);

    % Locate indices of points that exceed control limits
    idxUpperWarLimT2 = find(T2 > UpperWarLimT2);
    idxUpperWarLimQ = find(Q > UpperWarLimQ);
    idxUpperActLimT2 = find(T2 > UpperActLimT2);
    idxUpperActLimQ = find(Q > UpperActLimQ);
    idxHighT2Q = intersect(idxUpperActLimT2, idxUpperActLimQ);

    nobs = length(data(:,1));

    % Classify observations depending on their variations
    class = string(ones(1, nobs));
    class(idxUpperWarLimT2) = "ModerateT2Dev";
    class(idxUpperWarLimQ) = "ModerateQDev";
    class(idxUpperActLimT2) = "SevereT2Dev";
    class(idxUpperActLimQ) = "SevereQDev";
    class(idxHighT2Q) = "Common";
    class = categorical(class)';

    if select
        objN = find(class ~= "Common", 1):nobs;
    else
        objN = 1:nobs;
    end

    % Plot Control Charts
    figure;
    subplot(2, 1, 1);
    plot(objN, T2(objN));
    hold on;
    plot([min(objN), max(objN)], [UpperWarLimT2, UpperWarLimT2], 'b--');
    plot([min(objN), max(objN)], [UpperActLimT2, UpperActLimT2], 'r');
    % legend('data points','2 std dev below mean', '2 std dev above mean', '3 std dev below mean', '3 std dev above mean');
    xlabel("Observation");
    ylabel("T2 value");
    title('T2 Control Chart');
    hold off;

    subplot(2, 1, 2);
    plot(objN, Q(objN));
    hold on;
    plot([min(objN), max(objN)], [UpperWarLimQ, UpperWarLimQ], 'b--');
    plot([min(objN), max(objN)], [UpperActLimQ, UpperActLimQ], 'r');
    xlabel("Observation");  
    ylabel("SPEx");
    title('SPEx Control Chart');
    hold off;
    

end