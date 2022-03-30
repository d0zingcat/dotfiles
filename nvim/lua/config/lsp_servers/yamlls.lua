return {
    filetypes = { 'yaml', 'yml' },
    settings = {
        yaml = {
            schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                Kubernetes = { '/*k8s.yaml', '/*k8s.yml' },
                --['https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json'] = '/*.k8s.yaml',
            },
        },
    },
}
