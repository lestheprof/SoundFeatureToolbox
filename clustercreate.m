for components = 4:1:16
for clusts = 3:1:24
    clusterpcaica_fn(timitlocn, ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'pcastouse', components, ...
        'icastouse', components, 'clusters_pca', clusts, 'clusters_ica', clusts) ;
    [f1{(components-3), (clusts-2)}, m1{(components-3), (clusts-2)}] = processclusters_fn(timitlocn, 'expt_all_PCA.mat', ...
        ['clustertest_C' num2str(components) '_clusts' num2str(clusts)], 'const_phonfraction', 1.0) ;
end
end
save('clusterresults13032104', 'f1', 'm1') ;

