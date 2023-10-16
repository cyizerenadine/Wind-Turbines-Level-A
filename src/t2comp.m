function T2 = t2comp(data, loadings, latent, comp)
        score = data * loadings(:,1:comp);
        standscores = bsxfun(@times, score(:,1:comp), 1./sqrt(latent(1:comp,:))');
        T2 = sum(standscores.^2,2);
end