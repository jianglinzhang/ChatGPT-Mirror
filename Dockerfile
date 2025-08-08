# --- 前端构建阶段 (保持不变) ---
FROM node:22-slim AS builder
WORKDIR /app
COPY ./frontend/package.json ./frontend/package-lock.json ./frontend/
RUN cd frontend && npm install
COPY ./frontend/ ./frontend/
RUN cd frontend && npm run build

# --- 后端最终镜像 ---
FROM python:3.13-alpine
LABEL maintainer="dairoot"
WORKDIR /app
ENV DJANGO_ENV=PRODUCTION

RUN apk add --update caddy

# --- 修改部分开始 ---

# 将 requirements.txt 复制到 /app/requirements.txt
COPY ./backend/requirements.txt ./requirements.txt

# 直接在 /app 目录运行 pip，因为 WORKDIR 已经是 /app
RUN pip install -U pip && pip install -r requirements.txt

# 将 backend 目录的 *内容* 复制到 /app
COPY ./backend/ .

# --- 修改部分结束 ---

COPY ./Caddyfile /app/Caddyfile
COPY --from=builder /app/frontend/dist ./frontend/dist
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 50002
USER 10014
CMD ["/usr/local/bin/entrypoint.sh"]


# FROM node:22-slim AS builder

# WORKDIR /app

# COPY ./frontend/package.json ./frontend/package.json
# COPY ./frontend/package-lock.json ./frontend/package-lock.json

# RUN cd frontend && npm install 

# COPY ./frontend/ ./frontend/

# RUN cd frontend && npm run build

# FROM python:3.13-alpine

# LABEL maintainer="dairoot"

# WORKDIR /app

# ENV DJANGO_ENV=PRODUCTION

# RUN apk add --update caddy

# COPY ./backend/requirements.txt ./backend/requirements.txt

# RUN cd backend && pip install -U pip && pip install -r requirements.txt

# COPY ./backend/ ./backend/

# COPY ./Caddyfile /app/Caddyfile

# COPY --from=builder /app/frontend/dist ./frontend/dist

# COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# RUN chmod +x /usr/local/bin/entrypoint.sh

# EXPOSE 50002
# USER 10014
# CMD ["/usr/local/bin/entrypoint.sh"]

