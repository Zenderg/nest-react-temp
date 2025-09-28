version_settings(constraint='>=0.22.2')

# -----------------------------

load('ext://cert_manager', 'deploy_cert_manager')
deploy_cert_manager(load_to_kind=True)

k8s_yaml('deploy/infra/certs.yaml')
k8s_yaml('deploy/infra/nginx-ingress.yaml')

k8s_resource(
    'ingress-nginx-controller',
    port_forwards=['8080:80', '8443:443'],
    labels=['ingress']
)

# -----------------------------

k8s_yaml('deploy/postgres.yaml')

k8s_resource(
    'postgres',
    port_forwards=['5432:5432'],
    labels=['backend'],
    links=['postgresql://user:password@127.0.0.1:5432/db']
)

docker_build(
    'backend',
    context='.',
    dockerfile='./deploy/backend.dockerfile',
    only=['./backend'],
    live_update=[
        sync('./backend', '/app'),
        run(
            'cd app && pnpm install',
            trigger=['./backend/package.json', './backend/pnpm-lock.yaml']
        ),
        run(
            'cd app && prisma generate',
            trigger=['./backend/schema.prisma']
        )
    ]
)

k8s_yaml('deploy/backend.yaml')

k8s_resource('backend', labels=['backend'], links=['https://backend.local:8443'], resource_deps=['postgres'])

docker_build(
    'web',
    context='.',
    dockerfile='./deploy/web.dockerfile',
    only=['./client/web'],
    live_update=[
        fall_back_on('./client/web/vite.config.js'),
        sync('./client/web', '/app'),
        run(
            'cd app && pnpm install',
            trigger=['./client/web/package.json', './client/web/pnpm-lock.yaml']
        )
    ]
)

k8s_yaml('deploy/web.yaml')

k8s_resource('web', labels=['client'], links=['https://web.local:8443'])

docker_build(
    'mobile',
    context='.',
    dockerfile='./deploy/mobile.dockerfile',
    only=['./client/mobile'],
    live_update=[
        sync('./client/mobile', '/app'),
        run(
            'cd app && pnpm install',
            trigger=['./client/mobile/package.json', './client/mobile/pnpm-lock.yaml']
        )
    ]
)

k8s_yaml('deploy/mobile.yaml')

k8s_resource('mobile', labels=['client'], links=['https://mobile.local:8443'])

# -----------------------------

tiltfile_path = config.main_path

if config.tilt_subcommand == 'up':
    print("""
    \033[32m\033[32mStart to up all components...\033[0m

    If this is your first time using Tilt and you'd like some guidance, we've got a tutorial to accompany this project:
    https://docs.tilt.dev/tutorial
    """.format(tiltfile=tiltfile_path))