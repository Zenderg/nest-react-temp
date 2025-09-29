FROM node:22.20-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN apt update && apt install -y procps openssl && apt clean && corepack enable

WORKDIR /app
COPY backend/package.json .
COPY backend/pnpm-lock.yaml .

FROM base AS deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

FROM base
COPY backend .
COPY --from=deps /app/node_modules /app/node_modules

RUN cp .env.example .env

COPY schema /schema

CMD [ "pnpm", "run", "start:dev" ]