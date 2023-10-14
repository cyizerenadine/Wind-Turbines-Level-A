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