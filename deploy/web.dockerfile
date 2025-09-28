FROM node:22.20-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app
COPY client/web/package.json .
COPY client/web/pnpm-lock.yaml .

FROM base AS deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

FROM base
COPY client/web .
COPY --from=deps /app/node_modules /app/node_modules

CMD [ "pnpm", "dev", "--host" ]