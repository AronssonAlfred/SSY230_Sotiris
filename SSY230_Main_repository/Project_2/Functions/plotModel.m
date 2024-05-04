function plotModel(x,y,varargin)


t = (1:length(x))';

plot(t,y);

for m = 1:length(varargin)
    model = varargin{m};
    if length(varargin)==1

        % Assuming you have `theta_hat` (your estimated parameter vector) and `P` (the covariance matrix of `theta_hat`)
        n_samples = 2000; % Number of samples for the Monte Carlo simulation
        d = length(model.theta); % Dimension of the parameter space
        confidence_level = 0.95; % Typically for a 95% confidence interval
        chi_sq_value = chi2inv(confidence_level, d); % Chi-squared value for the confidence level

        % Preallocate arrays to store parameter samples and function evaluations
        f_evals = zeros(length(x), n_samples); % Assuming x is a vector of input features

        % Generate parameter samples and corresponding function evaluations
        for i = 1:n_samples
            Delta_theta = randn(d, 1);
            Delta_theta = Delta_theta / norm(Delta_theta) * sqrt(chi_sq_value);
            theta_k = model.theta + sqrtm(model.variance) * Delta_theta; % Adjust the estimated parameter
            model_sample = model;
            model_sample.theta = theta_k;
            zero = max(model.na, model.nb + model.nk - 1);
            phi = uy2phi([zeros(zero,2); [y x]], [model.na, model.nb, model.nk]);
            phi(:,1) = [];
            model_sample.phi = phi;
            f_evals(:, i) = model_sample.phi*model_sample.theta; % Evaluate the function for the k-th sample
        end

        % Calculate upper and lower bounds of the function evaluations
        f_max = max(f_evals, [], 2);
        f_min = min(f_evals, [], 2);
        plot(t,f_min,'b')
        plot(t,f_max,'r')
        Xr = [t; flipud(t)]; % Note the semicolon to create a column vector
        Y = [f_min; flipud(f_max)]; % Concatenate y_min with flipped y_max

        fill(Xr, Y, 'g', 'FaceAlpha', 0.1, 'EdgeColor', 'none'); % Fill with green color and 10% opacity
    end
end
end
