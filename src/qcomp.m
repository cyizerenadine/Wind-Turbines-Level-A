function Qfac = qcomp(data, loadings, comp)
    score = data * loadings(:,1:comp);
    reconstructed = score * loadings(:,1:comp)';
    residuals = bsxfun(@minus, data, reconstructed);
    Qfac = sum(residuals.^2,2);
end