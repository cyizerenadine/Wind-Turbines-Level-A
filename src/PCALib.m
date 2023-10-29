classdef    PCALib 
    methods     ( Static = true )
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [T2, Q, class]=faultIdentification(data, limits, loadings, latent, comp)
                % Get the control limits
                UpperWarLimT2 = limits(1); UpperActLimT2 = limits(2); UpperWarLimQ = limits(3); UpperActLimQ = limits(4);
            
                % Calculate T2 and Q scores
                T2 = PCALib.t2comp(data, loadings, latent, comp);
                Q = PCALib.qcomp(data, loadings, comp);
            
                % Locate indices of points that exceed control limits
                idxUpperActLimT2 = find(T2 > UpperActLimT2);
                idxUpperActLimQ = find(Q > UpperActLimQ);
                idxHighT2Q = intersect(idxUpperActLimT2, idxUpperActLimQ);
            
                nobs = length(data(:,1));
            
                % Classify observations depending on their variations
                class = string(ones(1, nobs));
                class(idxHighT2Q) = "Out-of-Control";
                class(~ismember(1:nobs, idxHighT2Q)) = "Normal";
                class = categorical(class)';
            
                objN = 1:nobs;
            
                % Plot Control Charts
                figure;
                subplot(2, 1, 1);
                plot(objN, log(T2(objN)), 'color', '#0072BD');
                hold on;
                plot([min(objN), max(objN)], [log(UpperWarLimT2), log(UpperWarLimT2)], '--', 'Color', '#EDB120');
                plot([min(objN), max(objN)], [log(UpperActLimT2), log(UpperActLimT2)], 'r--');
                % legend('data points','2 std dev below mean', '2 std dev above mean', '3 std dev below mean', '3 std dev above mean');
                xlabel("Observation");
                ylabel("log (T2 value)");
                title('T^2 Control Chart');
                legend(["Log Scores", "Warning", "Alarm"]);
                hold off;
            
                subplot(2, 1, 2);
                plot(objN, log(Q(objN)), 'color', '#77AC30');
                hold on;
                plot([min(objN), max(objN)], [log(UpperWarLimQ), log(UpperWarLimQ)], '--', 'Color', '#EDB120');
                plot([min(objN), max(objN)], [log(UpperActLimQ), log(UpperActLimQ)], 'r--');
                xlabel("Observation");  
                ylabel("log(SPEx value)");
                title('SPEx Control Chart');
                legend(["Log Scores", "Warning", "Alarm"]);
                hold off;
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function pcaloocv(X)
                num_observations = size(X, 1);
                max_pcs = min(num_observations, size(X, 2));
                error1 = zeros(num_observations, max_pcs);
            
                % Loop over observations
                for n = 1:num_observations
                    % Create the training and test datasets
                    train_indices = [1:n-1, n+1:num_observations];
                    Xtrain = X(train_indices, :);
                    Xtest = X(n, :);
            
                    % Center the training and test data
                    mu = mean(Xtrain);
                    Xtrain = Xtrain - mu;
                    Xtest = Xtest - mu;
            
                    % Perform PCA on the training data
                    [~, ~, V] = svd(Xtrain, 'econ');
            
                    % Loop over the number of Principal Components (PCs)
                    for j = 1:max_pcs
                        % Calculate the projection matrix
                        P = V(:, 1:j) * V(:, 1:j)';
            
                        % Calculate errors 
                        err1 = Xtest * (eye(size(P)) - P + diag(diag(P)));
            
                        % Store errors
                        error1(n, j) = sum(err1(:).^2);
                    end
                end
            
                % Sum the errors across observations
                error1 = sum(error1);
            
                % Plot the results
                figure;
                plot(error1, 'r.-');
                xlabel('Number of Principal Components');
                ylabel('Cross-validation error');
                title('PRESS for Varying Number of Components')
                grid on;
                saveas(gcf, fullfile('images', 'LOOCVPRESSChart.png'));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Qfac = qcomp(data, loadings, comp)
                score = data * loadings(:,1:comp);
                reconstructed = score * loadings(:,1:comp)';
                residuals = bsxfun(@minus, data, reconstructed);
                Qfac = sum(residuals.^2,2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Qcontr   = qcontr(data, loadings, comp)
                score         = data * loadings(:,1:comp);
                reconstructed = score * loadings(:,1:comp)';
                residuals     = bsxfun(@minus, data, reconstructed);
                Qcontr        = sum(residuals.^2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function summaryOutput = summarystats(data)
                dim = size(data);
                noOfVar = dim(2);
                summaryOutput = array2table(zeros(noOfVar, 5));
                summaryOutput.Properties.VariableNames = {'Mean','Std dev.', 'Max','Min', 'Median'};
                rowNames = data.Properties.VariableNames;
                summaryOutput.Properties.RowNames = rowNames;
                
                for i=1:noOfVar
                    variable = data{:,i};
                    summaryOutput{i,1} = mean(variable);
                    summaryOutput{i,2} = std(variable);
                    summaryOutput{i,3} = max(variable);
                    summaryOutput{i,4} = min(variable);
                    summaryOutput{i,5} = median(variable);
            
                end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function T2 = t2comp(data, loadings, latent, comp)
                score = data * loadings(:,1:comp);
                standscores = bsxfun(@times, score(:,1:comp), 1./sqrt(latent(1:comp,:))');
                T2 = sum(standscores.^2,2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function T2varcontr    = t2contr(data, loadings, latent, comp)
                score           = data * loadings(:,1:comp);
                standscores     = bsxfun(@times, score(:,1:comp), 1./sqrt(latent(1:comp,:))');
                T2contr         = abs(standscores*loadings(:,1:comp)');
                T2varcontr      = sum(T2contr,1);
        end
    end
end