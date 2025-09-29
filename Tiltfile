version_settings(constraint='>=0.22.2')

def check_node_version():
    min_major = 22

    res = local('node -v', quiet=True)
    node_version = str(res).lstrip('v').strip()
    major = int(node_version.split('.')[0])

    if major < min_major:
        fail("❌ Node.js version " + node_version + " is too low. Please use >= " + str(min_major))
    print("✅ Node.js version " + node_version + " - good")

# -----------------------------

check_node_version()

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

print("install deps for all local services...")

local_resource(
    "backend modules",
    cmd="cd ./backend && pnpm install",
    deps=["./backend/package.json"],
    labels=["local"]
)

local_resource(
    "backend gql schema",
    cmd="cd ./backend && pnpm codegen",
    deps=["./schema"],
    labels=["local"]
)

local_resource(
    "backend prisma types",
    cmd="cd ./backend && pnpx prisma generate",
    deps=["./backend/schema.prisma"],
    labels=["local"]
)

local_resource(
    "web modules",
    cmd="cd ./client/web && pnpm install",
    deps=["./client/web/package.json"],
    labels=["local"]
)

local_resource(
    "web gql schema",
    cmd="cd ./client/web && pnpm codegen",
    deps=["./backend/src/graphql.ts", "./client/web/codegen.ts"],
    resource_deps=["backend"],
    labels=["local"],
)

local_resource(
    "web gql schema watcher",
    serve_cmd="cd ./client/web && pnpm codegen --watch",
    labels=["local"],
    allow_parallel=True
)

local_resource(
    "mobile modules",
    cmd="cd ./client/mobile && pnpm install",
    deps=["./client/mobile/package.json"],
    labels=["local"]
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
    only=['./backend', './schema'],
    ignore=[
        './backend/node_modules',
        './backend/dist',
        './backend/test',
        './backend/.env',
        './backend/_tmp_*'
    ],
    live_update=[
        sync('./backend', '/app'),
        sync('./schema', '/schema'),
        run(
            'pnpm install',
            trigger=['./backend/package.json', './backend/pnpm-lock.yaml']
        ),
        run(
            'pnpx prisma generate',
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
    ignore=[
        './client/web/node_modules',
        './client/web/dist',
        './client/web/build',
        './client/web/.react-router',
        './client/web/_tmp_*',
    ],
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

k8s_resource('web', labels=['client'], links=['https://web.local:8443'], resource_deps=['backend'])

# docker_build(
#     'mobile',
#     context='.',
#     dockerfile='./deploy/mobile.dockerfile',
#     only=['./client/mobile'],
#     ignore=[
#         './client/mobile/node_modules',
#         './client/mobile/_tmp_*',
#     ],
#     live_update=[
#         sync('./client/mobile', '/app'),
#         run(
#             'cd app && pnpm install',
#             trigger=['./client/mobile/package.json', './client/mobile/pnpm-lock.yaml']
#         )
#     ]
# )

# k8s_yaml('deploy/mobile.yaml')

# k8s_resource('mobile', labels=['client'], links=['https://mobile.local:8443'])

# -----------------------------

tiltfile_path = config.main_path

if config.tilt_subcommand == 'up':
    print("""
    \033[32m\033[32mStart to up all components...\033[0m
    """.format(tiltfile=tiltfile_path))