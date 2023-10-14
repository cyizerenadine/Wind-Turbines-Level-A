function pca_loocv(X)
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
end
