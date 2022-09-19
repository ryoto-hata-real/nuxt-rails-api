FROM ruby:3.1.2-alpine

ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git"
ARG DEV_PACKAGES="build-base curl-dev"

# 環境変数を定義　Dockerfile、コンテナ参照可
ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# Dockerfile内で指定した命令を実行する
# ${HOME} == /app
WORKDIR ${HOME}

# ホスト側のファイルをコンテナにコピー、Dockerfileが入っている階層以下を指定できる
# Gemfile* == Gemfile, Gemfile.lock
COPY Gemfile* ./

# apk ... Alpine linuxのコマンド
# update ... 利用可能なパッケージの最新リスト
# upgrade ... インストールされているパッケージを最新にする
# add ... パッケージのインストール
# --no-cache ... パッケージをキャッシュしない（軽量化）
# --virtual ... 仮装パッケージ（パッケージをまとめる）
# bundle install -j4  ... Gemインストール
# del build-dependencies ... パッケージを削除（bundle installが終わればいらないので削除している）
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    bundle config set force_ruby_platform true && \
    bundle install -j4 && \
    apk del build-dependencies


# dockerfileがあるディレクトリ全てのファイル
COPY . ./


# 生成されたコンテナ内で実行したいコマンド(-b ... プロセスを指定したアドレスに紐付けする)
CMD ["rails", "server", "-b", "0.0.0.0"]