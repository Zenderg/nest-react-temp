FROM node:22.20-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable

WORKDIR /app
COPY client/mobile/package.json .
COPY client/mobile/pnpm-lock.yaml .

FROM base AS deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

FROM base
COPY client/mobile .
COPY --from=deps /app/node_modules /app/node_modules

CMD [ "pnpm", "start" ]