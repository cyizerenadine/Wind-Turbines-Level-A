function reconstructed = scomp(data, loadings, comp)
    score = data * loadings(:,1:comp);
    reconstructed = score * loadings(:,1:comp)';
end