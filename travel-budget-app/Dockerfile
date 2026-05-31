FROM php:8.4-apache

# MySQLに接続するためのPDOドライバーをインストール
RUN docker-php-ext-install pdo pdo_mysql

# ApacheのDocumentRootをLaravelのpublicフォルダに変更
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -i 's|/var/www/html|${APACHE_DOCUMENT_ROOT}|g' /etc/apache2/sites-available/000-default.conf

# .htaccessを有効にするためmod_rewriteを有効化
RUN a2enmod rewrite