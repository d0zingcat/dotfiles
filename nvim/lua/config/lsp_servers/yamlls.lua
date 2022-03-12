return {
    filetypes = { 'yaml', 'yml' },
    settings = {
        yaml = {
            schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                Kubernetes = '/*k8s.yaml',
            },
        },
    },
}
