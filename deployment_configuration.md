# docker-compose.yml - Complete Production Setup
version: '3.8'

services:
  web:
    build: 
      context: .
      dockerfile: Dockerfile.production
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/agency_production
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
    depends_on:
      - db
      - redis
    volumes:
      - ./storage:/rails/storage
    command: bundle exec rails server -b 0.0.0.0
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  sidekiq:
    build: 
      context: .
      dockerfile: Dockerfile.production
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/agency_production
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./storage:/rails/storage
    command: bundle exec sidekiq
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=agency_production
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./config/database/postgresql.conf:/etc/postgresql/postgresql.conf
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      - ./config/redis/redis.conf:/usr/local/etc/redis/redis.conf
    command: redis-server /usr/local/etc/redis/redis.conf
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./config/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./config/nginx/sites-enabled:/etc/nginx/sites-enabled
      - ./storage/logs/nginx:/var/log/nginx
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

---

# Dockerfile.production
FROM ruby:3.2.0-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    npm \
    curl \
    imagemagick \
    vips \
    tzdata

# Set working directory
WORKDIR /rails

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config --global frozen 1 && \
    bundle install --without development test && \
    bundle clean --force && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name "*.c" -delete && \
    find /usr/local/bundle/gems/ -name "*.o" -delete

# Install JavaScript dependencies
COPY package.json package-lock.json ./
RUN npm ci --production && npm cache clean --force

# Copy application code
COPY . .

# Precompile assets
RUN RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    bundle exec rails assets:precompile

# Create non-root user
RUN addgroup -g 1000 rails && \
    adduser -D -s /bin/sh -u 1000 -G rails rails && \
    chown -R rails:rails /rails

USER rails

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

---

# config/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;

    # Performance optimizations
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        application/atom+xml
        application/geo+json
        application/javascript
        application/x-javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rdf+xml
        application/rss+xml
        application/xhtml+xml
        application/xml
        font/eot
        font/otf
        font/ttf
        image/svg+xml
        text/css
        text/javascript
        text/plain
        text/xml;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=contact:10m rate=2r/m;

    # Include site configurations
    include /etc/nginx/sites-enabled/*;
}

---

# config/nginx/sites-enabled/agency.conf
upstream rails {
    server web:3000;
    keepalive 32;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name digitalforge.com www.digitalforge.com;
    return 301 https://$server_name$request_uri;
}

# Main HTTPS server
server {
    listen 443 ssl http2;
    server_name digitalforge.com www.digitalforge.com;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE+AESGCM:ECDHE+AES256:ECDHE+AES128:!aNULL:!MD5:!DSS;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.tailwindcss.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' https:;" always;

    # Document root
    root /rails/public;
    index index.html;

    # Asset caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri @rails;
    }

    # Static files
    location / {
        try_files $uri @rails;
    }

    # API rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://rails;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Contact form rate limiting
    location /leads {
        limit_req zone=contact burst=5 nodelay;
        proxy_pass http://rails;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Rails application
    location @rails {
        proxy_pass http://rails;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check
    location /health {
        access_log off;
        proxy_pass http://rails;
        proxy_set_header Host $host;
    }
}

---

# config/redis/redis.conf
# Performance optimizations
maxmemory 256mb
maxmemory-policy allkeys-lru
tcp-keepalive 60
timeout 300

# Persistence
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes

# Logging
loglevel notice
logfile /data/redis.log

---

# config/database/postgresql.conf
# Performance tuning for production
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200

# Logging
log_min_duration_statement = 1000
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on

---

# config/environments/production.rb - Performance optimizations
Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000'
  }

  # Asset configuration
  config.assets.compile = false
  config.assets.digest = true
  config.assets.css_compressor = :sass
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Active Storage
  config.active_storage.variant_processor = :vips
  
  # Caching
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    pool_size: ENV.fetch('RAILS_MAX_THREADS', 5).to_i,
    pool_timeout: 5,
    namespace: 'agency_cache'
  }

  # Session store
  config.session_store :redis_session_store,
    key: '_agency_session',
    redis: {
      url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
      expire_after: 2.weeks,
      key_prefix: 'agency:session:'
    }

  # Background jobs
  config.active_job.queue_adapter = :sidekiq

  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::Logger.new(STDOUT)

  # Security
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path =~ /health/ } } }
  
  # Email delivery
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'digitalforge.com', protocol: 'https' }
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_HOST'],
    port: ENV.fetch('SMTP_PORT', 587),
    domain: 'digitalforge.com',
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Performance monitoring
  config.middleware.use Rack::Deflater
  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'digitalforge.com', 'www.digitalforge.com'
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: true
    end
  end
end

---

# config/sidekiq.yml
:concurrency: 10
:timeout: 8
:verbose: false
:queues:
  - critical
  - default
  - low

:scheduler:
  lead_cleanup:
    cron: '0 2 * * *'
    class: LeadCleanupJob
  
  performance_report:
    cron: '0 6 * * 1'
    class: PerformanceReportJob

  backup_database:
    cron: '0 3 * * *'
    class: DatabaseBackupJob

---

# config/initializers/performance.rb
# Database connection pooling
Rails.application.configure do
  config.database_configuration[Rails.env]['pool'] = ENV.fetch('DB_POOL', 10).to_i
  config.database_configuration[Rails.env]['reaping_frequency'] = ENV.fetch('DB_REAPING_FREQUENCY', 10).to_i
  config.database_configuration[Rails.env]['dead_connection_timeout'] = ENV.fetch('DB_DEAD_CONNECTION_TIMEOUT', 5).to_i
end

# Redis configuration
$redis = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  timeout: 1,
  reconnect_attempts: 3,
  reconnect_delay: 0.5,
  reconnect_delay_max: 5.0
)

# Image processing optimizations
Rails.application.configure do
  config.active_storage.variant_processor = :vips
  config.active_storage.analyzers.delete ActiveStorage::Analyzer::ImageAnalyzer
  config.active_storage.analyzers.append ActiveStorage::Analyzer::ImageAnalyzer::Vips
end

---

# lib/tasks/deployment.rake
namespace :deploy do
  desc "Deploy application to production"
  task :production do
    puts "🚀 Deploying to production..."
    
    # Pre-deployment checks
    Rake::Task['deploy:check_requirements'].invoke
    
    # Build and deploy
    system("docker-compose -f docker-compose.yml build --no-cache")
    system("docker-compose -f docker-compose.yml up -d")
    
    # Post-deployment tasks
    Rake::Task['deploy:migrate'].invoke
    Rake::Task['deploy:seed'].invoke
    Rake::Task['deploy:warm_cache'].invoke
    
    puts "✅ Deployment complete!"
  end

  desc "Check deployment requirements"
  task :check_requirements do
    required_env = %w[
      SECRET_KEY_BASE
      DATABASE_URL
      REDIS_URL
      SMTP_HOST
      SMTP_USERNAME
      SMTP_PASSWORD
    ]
    
    missing = required_env.select { |var| ENV[var].blank? }
    
    if missing.any?
      puts "❌ Missing required environment variables: #{missing.join(', ')}"
      exit 1
    end
    
    puts "✅ All required environment variables present"
  end

  desc "Run database migrations"
  task :migrate do
    system("docker-compose exec web bundle exec rails db:migrate")
  end

  desc "Seed database with initial data"
  task :seed do
    system("docker-compose exec web bundle exec rails db:seed")
  end

  desc "Warm application cache"
  task :warm_cache do
    puts "🔥 Warming cache..."
    
    # Warm key pages
    %w[/ /projects /services].each do |path|
      system("curl -s https://digitalforge.com#{path} > /dev/null")
    end
    
    puts "✅ Cache warmed"
  end
end

namespace :maintenance do
  desc "Create database backup"
  task :backup do
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_file = "backup_#{timestamp}.sql"
    
    system("docker-compose exec db pg_dump -U postgres agency_production > ./backups/#{backup_file}")
    system("gzip ./backups/#{backup_file}")
    
    puts "✅ Database backup created: #{backup_file}.gz"
  end

  desc "Monitor application health"
  task :health_check do
    endpoints = [
      'https://digitalforge.com/health',
      'https://digitalforge.com/',
      'https://digitalforge.com/projects'
    ]
    
    endpoints.each do |endpoint|
      response = `curl -s -o /dev/null -w "%{http_code}" #{endpoint}`
      
      if response == '200'
        puts "✅ #{endpoint} - OK"
      else
        puts "❌ #{endpoint} - Failed (#{response})"
      end
    end
  end

  desc "Clean up old logs and temporary files"
  task :cleanup do
    # Clean old log files (keep last 7 days)
    system("find ./storage/logs -name '*.log' -mtime +7 -delete")
    
    # Clean temporary uploads
    system("find ./storage/tmp -type f -mtime +1 -delete")
    
    # Clean old Active Storage variants
    system("docker-compose exec web bundle exec rails active_storage:purge_variants")
    
    puts "✅ Cleanup complete"
  end
end

---

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def show
    checks = {
      database: database_check,
      redis: redis_check,
      disk_space: disk_space_check,
      memory: memory_check
    }
    
    status = checks.values.all? ? :ok : :service_unavailable
    
    render json: {
      status: status == :ok ? 'healthy' : 'unhealthy',
      timestamp: Time.current.iso8601,
      checks: checks
    }, status: status
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute('SELECT 1')
    { status: 'healthy', message: 'Database connection OK' }
  rescue => e
    { status: 'unhealthy', message: e.message }
  end

  def redis_check
    $redis.ping == 'PONG'
    { status: 'healthy', message: 'Redis connection OK' }
  rescue => e
    { status: 'unhealthy', message: e.message }
  end

  def disk_space_check
    stat = Sys::Filesystem.stat('/')
    free_percent = (stat.bytes_free.to_f / stat.bytes_total * 100).round(2)
    
    if free_percent > 10
      { status: 'healthy', message: "#{free_percent}% disk space available" }
    else
      { status: 'unhealthy', message: "Only #{free_percent}% disk space available" }
    end
  rescue => e
    { status: 'unknown', message: e.message }
  end

  def memory_check
    memory_mb = `free -m | grep '^Mem:' | awk '{print $7}'`.to_i
    
    if memory_mb > 100
      { status: 'healthy', message: "#{memory_mb}MB memory available" }
    else
      { status: 'unhealthy', message: "Only #{memory_mb}MB memory available" }
    end
  rescue => e
    { status: 'unknown', message: e.message }
  end
end

---

# config/routes.rb - Add health check
Rails.application.routes.draw do
  # Health check endpoint
  get '/health', to: 'health#show'
  
  # ... existing routes
end

---

# .github/workflows/deploy.yml - CI/CD Pipeline
name: Deploy to Production

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  RUBY_VERSION: 3.2.0
  NODE_VERSION: 18

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: agency_test
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
      
      redis:
        image: redis:7
        options: --health-cmd "redis-cli ping" --health-interval 10s --health-timeout 5s --health-retries 5

    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: ${{ env.RUBY_VERSION }}
        bundler-cache: true
    
    - name: Setup Node
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
    
    - name: Install dependencies
      run: |
        npm ci
        bundle install
    
    - name: Setup test database
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/agency_test
        REDIS_URL: redis://localhost:6379/0
        RAILS_ENV: test
      run: |
        bundle exec rails db:create db:schema:load
    
    - name: Run tests
      env:
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/agency_test
        REDIS_URL: redis://localhost:6379/0
        RAILS_ENV: test
      run: |
        bundle exec rspec
        
    - name: Run security audit
      run: |
        bundle exec bundle audit --update
        npm audit --audit-level moderate

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy to production
      env:
        DEPLOY_HOST: ${{ secrets.DEPLOY_HOST }}
        DEPLOY_USER: ${{ secrets.DEPLOY_USER }}
        DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
      run: |
        echo "$DEPLOY_KEY" > deploy_key
        chmod 600 deploy_key
        ssh -i deploy_key -o StrictHostKeyChecking=no $DEPLOY_USER@$DEPLOY_HOST "cd /var/www/agency && git pull origin main && docker-compose up -d --build"